alert = log = console.log
WebGL = require 'node-webgl'
#{ mat4 } = require 'gl-matrix'
document = WebGL.document()
canvas = document.createElement 'canvas'
document.setTitle 'OpenGL Triangle'
gl = canvas.getContext 'webgl'
gl.viewportWidth = canvas.width
gl.viewportHeight = canvas.height

## Creates fragment shader (returns white color for any position)
#fshader = gl.createShader(gl.FRAGMENT_SHADER)
#gl.shaderSource fshader, "void main(void) {gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);}"
#gl.compileShader fshader
#alert "Error during fragment shader compilation:\n" + gl.getShaderInfoLog(fshader)  unless gl.getShaderParameter(fshader, gl.COMPILE_STATUS)
#
## Creates vertex shader (converts 2D point position to coordinates)
#vshader = gl.createShader(gl.VERTEX_SHADER)
#gl.shaderSource vshader, "attribute vec2 ppos; void main(void) { gl_Position = vec4(ppos.x, ppos.y, 0.0, 1.0);}"
#gl.compileShader vshader
#alert "Error during vertex shader compilation:\n" + gl.getShaderInfoLog(vshader)  unless gl.getShaderParameter(vshader, gl.COMPILE_STATUS)
#
## Creates program and links shaders to it
#program = gl.createProgram()
#gl.attachShader program, fshader
#gl.attachShader program, vshader
#gl.linkProgram program
#alert "Error during program linking:\n" + gl.getProgramInfoLog(program)  unless gl.getProgramParameter(program, gl.LINK_STATUS)
#
## Validates and uses program in the GL context
#gl.validateProgram program
#alert "Error during program validation:\n" + gl.getProgramInfoLog(program)  unless gl.getProgramParameter(program, gl.VALIDATE_STATUS)
#gl.useProgram program
#
## Gets address of the input 'attribute' of the vertex shader
#vattrib = gl.getAttribLocation(program, "ppos")
#alert "Error during attribute address retrieval"  if vattrib is -1
#gl.enableVertexAttribArray vattrib
#
## draw
#gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
#gl.disable(gl.DEPTH_TEST)
##gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
#
## Sets clear color to non-transparent dark blue and clears context
#gl.clearColor(0.0, 0.0, 0.5, 1.0)
#gl.clear(gl.COLOR_BUFFER_BIT)
#
## Initializes the vertex buffer and sets it as current one
#vbuffer = gl.createBuffer()
#gl.bindBuffer gl.ARRAY_BUFFER, vbuffer
#
## Puts vertices to buffer and links it to attribute variable 'ppos'
#vertices = new Float32Array([0.0, 0.5, -0.5, -0.5, 0.5, -0.5])
#gl.bufferData gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW
#gl.vertexAttribPointer vattrib, 2, gl.FLOAT, false, 0, 0
#
#
#
## Draws the object
#gl.drawArrays gl.TRIANGLES, 0, 3
##gl.flush()


a = ->
  setTimeout a, 1000
a()
