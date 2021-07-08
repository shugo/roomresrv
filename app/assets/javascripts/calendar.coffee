# place all the behaviors and hooks related to the matching controller here.
# all this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
    isMobile = window.matchMedia("only screen and (max-width: 760px)").matches

    h = (s) ->
        jQuery('<div>').text(s).html()

    attrNames = {
        start_at: "開始日時",
        end_at: "終了日時"
    }

    formatErrors = (errors) ->
        (es.map((e) -> h(attrNames[a] + e)) for a, es of errors).join("<br/>")

    eventEdited = (event, delta, revertFunc, jsEvent, ui, view) ->
        time = $.fullCalendar.formatRange(event.start, event.end,
                                          'YYYY-MM-DD HH:mm')
        msg = "「#{h(event.title)}」の日時を#{h(time)}に変更しますか？"
        bootbox.confirm msg, (result) ->
            if result
               ajaxSender(event.start,event.end,event.url)
                   .fail (xhr, status, suject) ->
                        revertFunc()
                        if xhr.status == 422
                            errors = $.parseJSON(xhr.responseText)
                            bootbox.alert("日時を変更できませんでした<br/>" +
                                          formatErrors(errors))
                        else
                            bootbox.alert("日時を変更できませんでした")
            else
                revertFunc()

    $('#calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month agendaWeek agendaDay'
        },
        dayClick: (date, jsEvent, view) ->
            if $('#calendar').fullCalendar('getView').name == 'month'
                $('#calendar').fullCalendar('gotoDate', date)
                $('#calendar').fullCalendar('changeView', 'agendaDay')
            else
                location.href = "/reservations/new?date=" + encodeURIComponent(date.format())
        ,
        allDaySlot: false,
        slotLabelFormat: 'H:mm',
        minTime: '08:00',
        maxTime: '24:00',
        timeFormat: 'H:mm',
        views: {
            month: {
                columnFormat: 'ddd',
                titleFormat: 'YYYY年M月'
            },
            agendaWeek: {
                columnFormat: if isMobile then 'ddd' else 'M/D（ddd）',
                titleFormat: if isMobile then 'M月D日' else 'YYYY年M月D日'
            },
            agendaDay: {
                columnFormat: 'M/D（ddd）',
                titleFormat: if isMobile then 'M月D日（ddd）' else 'YYYY年M月D日（ddd）'
            }
        },
        buttonText: {
            today:    '今日',
            month:    '月',
            week:     '週',
            day:      '日'
        },
        monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
        monthNamesShort: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
        dayNames: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
        dayNamesShort: ['日', '月', '火', '水', '木', '金', '土'],

        eventMouseover: (event,allDay,jsEvent) ->
          $('body').prepend(event.tooltip);
          max_width = window.innerWidth
          diff_disp = max_width - allDay.clientX
          if diff_disp > 300
            xOffset = 30 + $('#tooltip').height();
            yOffset = -20;
          else
            xOffset = -100 + $('#tooltip').height();
            yOffset = -100;

        

          $('#tooltip')
           .css('top', (allDay.clientY - xOffset) + 'px')
           .css('left', (allDay.clientX + yOffset) + 'px')
           .fadeIn();

        eventMouseout: (event) ->
          $("#tooltip").remove()

        events: {
               
            url: "/calendar/reservations",
            error: ->
                alert("予約データの取得に失敗しました")
        },
        eventRender: (event, element) ->
            dates = [event._start._d,
                 event._end._d]
            holiday_chack = JapaneseHolidays.isHoliday(dates[0])
            if holiday_chack && event.repeatingMode == "weekly"
              holidayMove(event,dates,1)

            purpose = h(event.purpose)
            representative = h(event.representative)
            note = event.note
            if note == null
              note = " " 
            else
              note = h(note)

            popup_msg = "担当者:#{representative} <br> 用途:#{purpose} <br> 会議室:#{event.room} <br> メモ:#{note}"
            event.tooltip =  '<span id="tooltip">' + popup_msg + '</span>'

            if ($('#room-select')[0] &&
                $('#room-select').val() == event.roomId.toString()) ||
               $('#room' + event.roomId).prop('checked')
                if event.repeatingMode == "weekly"
                     e = element.find(".fc-time")
                     if e.prop("tagName") != "SPAN"
                         e = e.find("span")
                     e.after('<i class="fa fa-refresh"></i>')
                element
            else
                false
        ,
        defaultView: Cookies.get("roomresrv_default_view") || "month",
        defaultDate: Cookies.get("roomresrv_default_date"),
        viewRender: (view, element) ->
            if view.name == "month"
                selector = ".fc-day-top"
            else
                selector = ".fc-day-header"
            element.find(selector).each ->
                if JapaneseHolidays.isHoliday(new Date($(this).attr("data-date")))
                    $(this).addClass("fc-holiday")
            Cookies.set("roomresrv_default_view", view.name, {expires: 30})
            Cookies.set("roomresrv_default_date",
                        $('#calendar').fullCalendar('getDate').format(),
                        {expires: 0.5})
        ,
        editable: true,
        eventLimit: true,
        eventLimitText: '件',
        dayPopoverFormat: 'M月D日（ddd）',
        eventDrop: eventEdited,
        eventResize: eventEdited
    })

$(document).on 'turbolinks:before-cache', ->
    $('#calendar').empty()
    $("#tooltip").remove()

@roomSelectionChanged = ->
    $('#calendar').fullCalendar 'rerenderEvents'
    if $('#room-select')[0]
        Cookies.set("roomresrv_room_id", $('#room-select').val())
    else
        rooms = ($(e).val() for e in $('.room-check') when $(e).prop('checked'))
        Cookies.set("roomresrv_selected_rooms", rooms.join(","),
                    {expires: 30})


@checkColorChanged = (checkid,roomcolor) ->
   roomid = "room" + checkid
   elements = document.getElementById(roomid)
   if elements.checked == true
      elements.parentNode.style.backgroundColor = roomcolor
   else
     elements.parentNode.style.backgroundColor = "#c2c4c6"

holidayMove = (event,date,direction) -> 
   set_day = [0,0]
   for day, i in date
     holiday_flag = true
     loop
       holiday = JapaneseHolidays.isHoliday(day)
       if holiday
         day.setDate(day.getDate() +  direction)
       set_day[i] = day
       sat_or_sun = set_day[i].getDay()
       unless holiday
          if (sat_or_sun == 0 && direction == 1) || (sat_or_sun == 6 && direction == -1)
             set_day[i].setDate(set_day[i].getDate() + (1 * direction))
          else if  (sat_or_sun == 0 && direction == -1) || (sat_or_sun == 6 && direction == 1)
             set_day[i].setDate(set_day[i].getDate() + (2 * direction))

       if !holiday && sat_or_sun > 0 && sat_or_sun < 6
           holiday_flag = false
       
       break unless holiday_flag

   event.start._d = set_day[0]
   event.end._d = set_day[1]
   ajaxSender(event.start,event.end,event.url)
                    .fail (xhr, status, suject) ->
                        if xhr.status == 422 &&  direction == 1
                          for day,i in set_day
                            set_day[i].setDate(day.getDate() - 1 )            
                          holidayMove(event,set_day,-1)                         

ajaxSender = (start,end,url) -> 
   $.ajax({
                    url: url,
                    method: "PATCH",
                    dataType: "json",
                    data: {
                              reservation: {
                                  start_at: start.format(),
                                  end_at: end.format()
                              }
                          }
                })
                    .done (xhr, status, suject) ->
                        $('#calendar').fullCalendar('refetchEvents')
 
 
   
# vim: set expandtab :
