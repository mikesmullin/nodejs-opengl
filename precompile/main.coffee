log = console.log
WebGL = require 'node-webgl'
{ mat4 } = require 'gl-matrix'
document = WebGL.document()
canvas = document.createElement 'canvas'
document.setTitle 'OpenGL Triangle'
gl = canvas.getContext 'webgl'
gl.viewportWidth = canvas.width
gl.viewportHeight = canvas.height
gl.enable gl.DEPTH_TEST
gl.depthFunc gl.LESS

points = [
   0.0,  0.5,  0.0,
   0.5, -0.5,  0.0,
  -0.5, -0.5,  0.0
]

vbo = gl.createBuffer()
gl.bindBuffer gl.ARRAY_BUFFER, vbo
gl.bufferData gl.ARRAY_BUFFER, new Float32Array(points), gl.STATIC_DRAW
vbo.itemSize = 3
vbo.numItems = 3


vao = gl.createBuffer()
gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, vao
gl.enableVertexAttribArray 0
gl.bindBuffer gl.ARRAY_BUFFER, vbo
gl.vertexAttribPointer 0, 3, gl.FLOAT, false, 0, 0

vs = gl.createShader gl.VERTEX_SHADER
gl.shaderSource vs, """
#version 400
out vec4 frag_colour;
void main () {
  frag_colour = vec4 (0.5, 0.0, 0.5, 1.0);
}
"""
gl.compileShader vs

fs = gl.createShader gl.FRAGMENT_SHADER
gl.shaderSource fs, """
#version 400
out vec4 frag_colour;
void main () {
  frag_colour = vec4 (0.5, 0.0, 0.5, 1.0);
}
"""
gl.compileShader fs

sp = gl.createProgram()
gl.attachShader sp, fs
gl.attachShader sp, vs
gl.linkProgram sp

gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
gl.useProgram sp

pMatrix = mat4.create()
mvMatrix = mat4.create()
mat4.perspective 45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix
mat4.identity mvMatrix
mat4.translate mvMatrix, [0.0, 0.0, 5]

(setMatrixUniforms = ->
  gl.uniformMatrix4fv sp.pMatrixUniform, false, pMatrix
  gl.uniformMatrix4fv sp.mvMatrixUniform, false, mvMatrix
)()

gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, vao
gl.drawElements gl.TRIANGLES, 0, gl.UNSIGNED_SHORT, 3
