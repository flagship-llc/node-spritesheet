path = require( "path" )

class Style

  constructor: ( options ) ->
    @selector = options.selector
    @pixelRatio = options.pixelRatio || 1
    @forceRetina = options.forceRetina || false

    @resolveImageSelector = options.resolveImageSelector if options.resolveImageSelector

  css: ( selector, attributes ) ->
    "#{ selector } {\n#{ @cssStyle( attributes ) };\n}\n"

  cssStyle: ( attributes ) ->
    attributes.join ";\n"

  cssComment: ( comment ) ->
    "/*\n#{ comment }\n*/"

  resolveImageSelector: ( name ) ->
    name

  generate: ( options ) ->
    { imagePath, relativeImagePath, images, pixelRatio, width, height } = options
    relativeImagePath = relativeImagePath.replace /(\\+)/g, "/"
    @pixelRatio = pixelRatio || 1

    logicalWidth = width
    logicalHeight = height

    if @forceRetina == true
      pixelRatio = 2

      logicalHeight = logicalHeight / pixelRatio
      logicalWidth = logicalWidth / pixelRatio

    styles = [
      @css @selector, [
        "  overflow: hidden"
        "  position: relative"
      ]
      @css "#{@selector} img", [
        "  display: block"
        "  position: absolute"
        "  width: #{logicalWidth}px"
        "  height: #{logicalHeight}px"
      ]
    ]

    if pixelRatio is 1 or @forceRetina == true
      for image in images
        positionX = ( -image.cssx / pixelRatio )
        if positionX != 0
          positionX = positionX+'px'

        positionY = ( -image.cssy / pixelRatio )
        if positionY != 0
          positionY = positionY+'px'

        attr = [
          "  width: #{ image.cssw / pixelRatio }px"
          "  height: #{ image.cssh / pixelRatio }px"
        ]

        imgAttr = [
          "  left: #{positionX}"
          "  top: #{positionY}"
        ]

        image.style = @cssStyle attr
        image.selector = @resolveImageSelector( image.name, image.path )

        mainSelector = [ @selector, image.selector ].join( '.' )

        styles.push @css( mainSelector, attr )
        styles.push @css( "#{mainSelector} img", imgAttr )

    styles.push ""
    css = styles.join "\n"

    if pixelRatio > 1 and !@forceRetina
      css = @wrapMediaQuery( css )

    return css

  comment: ( comment ) ->
    @cssComment comment

  wrapMediaQuery: ( css ) ->
    "@media (min--moz-device-pixel-ratio: #{ @pixelRatio }),\n
(-o-min-device-pixel-ratio: #{ @pixelRatio }/1),\n
(-webkit-min-device-pixel-ratio: #{ @pixelRatio }),\n
(min-device-pixel-ratio: #{ @pixelRatio }) {\n
#{ css }
}\n"

module.exports = Style
