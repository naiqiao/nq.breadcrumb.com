iframesToLoad = []

window.onYouTubeIframeAPIReady = () ->
  for frame in iframesToLoad
    player = new YT.Player frame.playerId,
      videoId: frame.videoId
      playerVars:
        showinfo: frame.showTitle
        controls: frame.showControls

    frameTarget = $("##{frame.playerId}")[0]
    frameTarget.player = player

  if Yext?.Callbacks?.ytPlayersReady?
    Yext.Callbacks.ytPlayersReady()

getYouTubeThumbnailUrlFromPageUrl = (videoId, thumbnailIndex) ->
  "http://img.youtube.com/vi/#{videoId}/#{thumbnailIndex}.jpg"

getYouTubeVideoIdFromPageUrl = (pageUrl) ->
  matches = /(youtu(?:\.be|be\.com)\/(?:.*v(?:\/|=)|(?:.*\/)?)([\w'-]+))/i.exec(pageUrl)

  if matches?.length
    matches[matches.length - 1]
  else
    pageUrl

$ ->
  $ '[data-youtubeurl]'
    .each (index) ->
      $this = $ @
      youTubeSource = $this.data 'youtubeurl'
      videoId = getYouTubeVideoIdFromPageUrl(youTubeSource)

      if $this.is 'img'
        thumbnailIndex = $this.data 'thumbnailindex' || 0
        $this.attr 'src', getYouTubeThumbnailUrlFromPageUrl(videoId, thumbnailIndex)

      else
        iframesToLoad.push
          videoId: videoId
          showTitle: $this.data 'showtitle' || 0
          showControls: if $this.data 'showcontrols' then 1 else 0
          playerId: $this.attr 'id'


  if iframesToLoad.length > 0
    $($('script')[0]).prepend($('<script src="https://www.youtube.com/iframe_api"></script>'))