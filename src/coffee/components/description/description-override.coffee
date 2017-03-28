$ ->
  $(".c-description .js-show-more").click (e) ->
    description = $(@).closest(".c-description")
    description.addClass "show-full-description"
    e.preventDefault()

  $(".c-description .js-show-less").click (e) ->
    description = $(@).closest(".c-description")
    description.removeClass "show-full-description"
    e.preventDefault()