initPrograms = ->

  $target = $ '#js-program-description'
  $target.collapse({toggle: false})

  $desktopContents = $ '.js-programs-description'

  $ '.js-program-toggle'
    .click ->

      targetContent = $(@).data 'desktop-target'

      unless $(@).hasClass 'is-expanded'
        for el in $desktopContents
          if not $desktopContents.hasClass 'is-hidden' and not "##{$desktopContents.attr('id')}" == targetContent
            $(el).addClass 'is-hidden'

        $(targetContent).toggleClass 'is-hidden'

      if $(@).hasClass 'is-expanded'
        # click on currently expanded link, remove content
        $target.collapse 'hide'
      else
        # click on unexpanded link
        # and remove is-expanded flag on whatever is current

        $ '.js-program-toggle.is-expanded'
          .removeClass 'is-expanded'

        unless $target.hasClass 'collapse' and $target.hasClass 'in'
          $target.collapse 'show'

      $(@).toggleClass 'is-expanded'

initCarousel = ->

  if $('#js-carousel').length and $('#js-carousel').height() == 0
    $('#js-carousel-container').addClass('ie-fix')
    $('#js-carousel').height($('#js-carousel-ie-fix').height())

  $ '.js-carousel-description'
    .on 'shown.bs.collapse', ->
      height = $(@).height()
      $ '#js-carousel'
        .toggleClass 'is-expanded'
    .on 'hidden.bs.collapse', ->
      $ '#js-carousel'
        .toggleClass 'is-expanded'

  toggleAria = (slide) ->
    hidden = $(slide).attr('aria-hidden') == 'true'
    $(slide).attr('aria-hidden', !hidden)

  elligibleIndex = (targetIndex) ->
    maxIndex = $('.js-carousel-item').length-1
    switch
      when targetIndex > maxIndex then 0
      when targetIndex < 0 then maxIndex
      else targetIndex

  changeSlide = (increment) ->

    currentSlide = $(".js-carousel-item[aria-hidden='false']")
    currentIndex = parseInt($(currentSlide).data('index'))

    targetIndex = elligibleIndex(currentIndex + increment)
    newNextIndex = elligibleIndex(targetIndex+1)
    newPreviousIndex = elligibleIndex(targetIndex-1)

    toggleAria(currentSlide)
    toggleAria($("#js-carousel-item-#{targetIndex}"))

    baseClasses = 'carousel-item js-carousel-item'

    $(".js-carousel-item").attr 'class', baseClasses

    $("#js-carousel-item-#{targetIndex}")
      .attr 'class', "#{baseClasses} is-current"
    $("#js-carousel-item-#{newNextIndex}")
      .attr 'class', "#{baseClasses} is-next#{if increment == -1 then ' is-in-transition'  else ''}"
    $("#js-carousel-item-#{newPreviousIndex}")
      .attr 'class', "#{baseClasses} is-prev#{ if increment == 1 then' is-in-transition' else ''}"

  changeSlideAuto = ->
    changeSlide(1)

  $ ->
    carouselSlideAuto = setInterval(changeSlideAuto, 5000)
    $ ('#js-carousel')
      .mouseenter ->
        carouselSlideAuto = clearInterval(carouselSlideAuto)
      .mouseleave ->
        carouselSlideAuto = setInterval(changeSlideAuto, 5000)

  $ '#js-carousel-next'
    .click ->
      changeSlide(1)

  $ '#js-carousel-prev'
    .click ->
      changeSlide(-1)

  $ '.js-carousel-item'
    .on 'transitionend', ->
      $ @
        .removeClass 'is-in-transition'

$ ->
  initPrograms()
  initCarousel()

  isBingUetStore = jQuery.parseJSON($('#isBingUetStore').html()).isBingUetStore
  if $('#nameOfLocalSchool').length > 0 then localSchoolQuery = $('#nameOfLocalSchool').html() else localSchoolQuery = 0
  nameOfLocalSchool = ''
  if localSchoolQuery.length > 0
    nameOfLocalSchool = jQuery.parseJSON(localSchoolQuery).nameOfLocalSchool

  if $('#twitterID').length > 0 then isTwitterStore = true and twitterID = jQuery.parseJSON($('#twitterID').html()).twitterID else isTwitterStore = false

  $('#form-thankyou').on 'show.bs.modal', ->
    if isBingUetStore
      pixelBingUetLeadSubmissionModal = "<!-- Bing Pixel Code -->
        <script>(function(w,d,t,r,u){var f,n,i;w[u]=w[u]||[],f=function(){var o={ti:'5278876'};o.q=w[u],w[u]=new UET(o),w[u].push('pageLoad')},n=d.createElement(t),n.src=r,n.async=1,n.onload=n.onreadystatechange=function(){var s=this.readyState;s&&s!=='loaded'&&s!=='complete'||(f(),n.onload=n.onreadystatechange=null)},i=d.getElementsByTagName(t)[0],i.parentNode.insertBefore(n,i)})(window,document,'script','//bat.bing.com/bat.js','uetq');</script><noscript><img src='//bat.bing.com/action/0?ti=5278876&Ver=2' height='0' width='0' style='display:none; visibility: hidden;' /></noscript>
        <script>
        window.uetq = window.uetq || [];
        window.uetq.push
        ({ 'ec':' Lead Submission ', 'ea':'Lead Submitted', 'el':'" + nameOfLocalSchool + " Lead ', 'ev':' 1' });
        </script>
        <!-- End Bing Pixel Code -->"
      $("head").append(pixelBingUetLeadSubmissionModal)

    if isTwitterStore
      pixelTwitterLeadSubmissionModal = "<!-- Twitter single-event website tag code -->
        <script src='//platform.twitter.com/oct.js' type='text/javascript'></script>
          <script type='text/javascript'>
            twttr.conversion.trackPid('" + twitterID + "',{ tw_sale_amount: 0, tw_order_quantity: 0 });
          </script>
        <noscript>
        <img height='1' width='1' style='display:none;' alt='' src='https://analytics.twitter.com/i/adsct?txn_id=nvddq&p_id=Twitter&tw_…' />
        <img height='1' width='1' style='display:none;' alt='' src='//t.co/i/adsct?txn_id=" + twitterID + "&p_id=Twitter&tw_sale_amount=0&tw_order_quantity=0' />
        </noscript>
        <!-- End Twitter single-event website tag code -->"
      $("head").append(pixelTwitterLeadSubmissionModal)

    if $('#form-thankyou').attr('data-storeid') == '295'
      s = "<!-- Facebook Pixel Code -->
          <script>
          !function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
          n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
          n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
          t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
          document,'script','//connect.facebook.net/en_US/fbevents.js');

          fbq('init', '673269422808293');
          fbq('track', 'PageView');

          // Lead
          // Track when a user expresses interest in your offering (ex. form submission, sign up for trial, landing on pricing page)
          fbq('track', 'Lead');

          </script>
          <noscript><img height='1' width='1' style='display:none'
          src='https://www.facebook.com/tr?id=673269422808293&ev=PageView&noscript=1'
          /></noscript>
          <!-- End Facebook Pixel Code -->"
      $("head").append(s)
