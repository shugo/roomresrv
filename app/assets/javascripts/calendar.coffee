# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$.cookie.defaults.path = "/"

$ ->
    $('#calendar').fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month agendaWeek agendaDay'
        },
#        theme: false,
#        firstDay: 0,
#        weekends: true,
#        weekMode: 'fixed',
#        weekNumbers: false,
#        viewDisplay: (view) ->
#            alert('ビュー表示イベント ' + view.title)
#        ,
#        windowResize: (view) ->
#            alert('ウィンドウリサイズイベント')
#        ,
        dayClick: (date, jsEvent, view) ->
            if ($('#calendar').fullCalendar('getView').name == 'month')
                $('#calendar').fullCalendar('gotoDate', date)
                $('#calendar').fullCalendar('changeView', 'agendaDay')
            else
                location.href = "/reservations/new?date=" + encodeURIComponent(date.format())
        ,
        defaultView: 'month',
        allDaySlot: true,
        allDayText: '終日',
        axisFormat: 'H:mm',
#        slotMinutes: 15,
#        snapMinutes: 15,
#        firstHour: 9,
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
#        selectable: true,
#        selectHelper: true,
#        unselectAuto: true,
#        unselectCancel: '',
        events: {
            url: "/calendar/reservations",
            error: ->
                alert("予約データの取得に失敗しました")
        },
        defaultView: $.cookie("defaultView") || "month",
        defaultDate: $.cookie("defaultDate"),
        viewRender: (view, element) ->
            $.cookie("defaultView", view.name)
            $.cookie("defaultDate",
                     $('#calendar').fullCalendar('getDate').format())
    })
