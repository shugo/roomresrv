# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

reservationDuration = 1 * 60 * 60 * 1000

getDate = (name) ->
    year = parseInt($(name + "_1i").val(), 10)
    month = parseInt($(name + "_2i").val(), 10)
    date = parseInt($(name + "_3i").val(), 10)
    hour = parseInt($(name + "_4i").val(), 10)
    min = parseInt($(name + "_5i").val(), 10)
    new Date(year, month - 1, date, hour, min)

setDate = (name, date) ->
    $(name + "_1i").val(date.getFullYear())
    $(name + "_2i").val(date.getMonth() + 1)
    $(name + "_3i").val(date.getDate())
    $(name + "_4i").val(to2Digits(date.getHours()))
    $(name + "_5i").val(to2Digits(date.getMinutes()))

to2Digits = (n) ->
    s = n.toString()
    if n < 10
        '0' + s
    else
        s

@reservationStartAtChanged = ->
    startAt = getDate("#reservation_start_at")
    endAt = new Date(startAt.getTime() + reservationDuration)
    setDate("#reservation_end_at", endAt)

@reservationEndAtChanged = ->
    reservationDuration =
        getDate("#reservation_end_at") - getDate("#reservation_start_at")
