$ ->
  $el = $('.js-email-share-link')

  siteUrl = window.location

  emailSubject = $el.data('email-subject')
  emailBody = $el.data('email-body')

  emailBody += "\n\n#{siteUrl}"

  URI.escapeQuerySpace = false

  url = URI("mailto:").query({subject: emailSubject, body: emailBody})

  $el.attr('href', url)
