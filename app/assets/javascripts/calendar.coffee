# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
    $.cookie.defaults.path = "/"

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
                $.ajax({
                    url: event.url,
                    method: "PATCH",
                    dataType: "json",
                    data: {
                              reservation: {
                                  start_at: event.start.format(),
                                  end_at: event.end.format()
                              }
                          }
                })
                    .error (xhr, status, suject) ->
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
        axisFormat: 'H:mm',
        minTime: '08:00',
        maxTime: '24:00',
        timeFormat: 'H:mm',
        columnFormat: {
            month: 'ddd',
            week: "M/D（ddd）",
            day: "M/D（ddd）"
        },
        titleFormat: {
            month: 'YYYY年M月',
            week: "YYYY年M月D日",
            day: "YYYY年M月D日（ddd）"
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
        events: {
            url: "/calendar/reservations",
            error: ->
                alert("予約データの取得に失敗しました")
        },
        eventRender: (event, element) ->
            if event.repeatingMode == "weekly"
                element.addClass("repeat-weekly")
        ,
        defaultView: $.cookie("defaultView") || "month",
        defaultDate: $.cookie("defaultDate"),
        viewRender: (view, element) ->
            $.cookie("defaultView", view.name, {expires: 30})
            $.cookie("defaultDate",
                     $('#calendar').fullCalendar('getDate').format())
        ,
        editable: true,
        eventDrop: eventEdited,
        eventResize: eventEdited
    })

# vim: set expandtab :
