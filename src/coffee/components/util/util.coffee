((root) ->
  provide = (obj, path, val=null) ->
    path = path.split "."
    [path..., last] = path if val?
    for p in path
      obj[p] = {} unless obj[p]?
      obj = obj[p]
    obj[last] = val if val?
    obj

  provide(root || {}, 'Yext.provide', provide)
)(if global? then global else this)