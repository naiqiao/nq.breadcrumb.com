class FormPayload
  constructor: (args) ->
    {@formArray, @group_id, @location_email, @lead_source, @referrer} = args

    for input in @formArray
      switch input.name
        when "first-name"
          @firstName = input.value

        when "last-name"
          @lastName = input.value

        when "email"
          @email = input.value

        when "phone"
          @phone = input.value

        when "instrument"
          @instrument = input.value
        when "opt-in"
          @opt_in = true

        else
          throw new Error "Unexpected form input '#{input.name}' with value '#{input.value}'"

  dataForSubmission: ->
    unless @opt_in?
      @opt_in = false
    return {
      "groupId": @group_id
      "recipient": @location_email
      "firstName": @firstName
      "lastName": @lastName
      "email": @email
      "phone": @phone
      "instrument": @instrument
      "leadSource": @lead_source
      "optIn": @opt_in
      "referrer": @referrer
    }

class window.Zd
  @url: JSON.parse($("#js-zendesk-url").text())

  @resetForm: ->
    $ 'form.js-zendesk'
      .find('input, select, textarea').val ''
      .find('input:radio, input:checkbox').removeAttr('checked').removeAttr 'selected'

  @setupForms: ->
    $ 'form.js-zendesk'
      .each (idx, el) ->
        el.zd = new window.Zd
          form: el
          group_id: $(el).data("group-id")
          location_email: $(el).data("recipient")

  constructor: (args) ->
    {@form, @group_id, @location_email} = args

    $ @form
      .submit @submitHandler

  submitHandler: (event) ->
    pl = new FormPayload
      formArray: $(@).serializeArray()
      group_id: @zd.group_id
      location_email: @zd.location_email
      lead_source: getLeadSource()
      referrer: document.referrer

    d = JSON.stringify(pl.dataForSubmission())

    $ '.zendesk-form-button'
      .prop "disabled", true

    $.ajax
      url: window.Zd.url
      type: "post"
      dataType: "json"
      data: d
      success: (data) ->
        trackConv(986463016, '6TKaCLig6AgQqPaw1gM', null, false)
        $ '#form-thankyou'
          .modal 'toggle'
        ga 'send',
          hitType: 'event',
          eventCategory: 'Lesson',
          eventAction: 'Lead_Generation',
          eventLabel: 'Success'

        if fbq?
          fbq('track', 'Lead')

        window.Zd.resetForm()
      complete: ()->
        $('.zendesk-form-button').prop("disabled", false)

    event.preventDefault()

  getLeadSource = () ->
    if getQueryVariable()
      getQueryVariable()
    else
      'Online'

  getQueryVariable = () ->
    new URI(window.location.href).query(true).labelSource

$ ->
  window.Zd.setupForms()