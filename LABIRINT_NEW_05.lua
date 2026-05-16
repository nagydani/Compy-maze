-- Generated from LABIRINT_NEW_05.svg
local gfx = love.graphics
local convex_fill = compy.graphics.shape2d.convex_fill
local concave_fill = compy.graphics.shape2d.concave_fill
local selfx_fill = compy.graphics.shape2d.selfx_fill
local bezier_stroke = compy.graphics.shape2d.bezier_stroke
local paths = { }

paths.p1 = { -- concave
  { "M", 0.49, 351.2 },
  { "L", 121.56, 351.2 },
  { "C", 141.41, 351.2, 157.66, 366.93, 157.66, 386.17 },
  { "L", 157.66, 505.71 },
  { "C", 157.66, 524.95, 141.41, 540.68, 121.56, 540.68 },
  { "L", 0.49, 540.68 },
  { "L", 0.49, 351.2 },
  { "Z" },
}
paths.p2 = { -- convex
  { "M", 910.43, 160.76 },
  { "L", 1023.79, 160.76 },
  { "L", 1024, 160.77 },
  { "L", 1024, 337.31 },
  { "L", 1023.79, 337.31 },
  { "L", 910.43, 337.31 },
  { "C", 891.92, 337.31, 876.79, 322.66, 876.79, 304.73 },
  { "L", 876.79, 193.34 },
  { "C", 876.79, 175.42, 891.92, 160.76, 910.43, 160.76 },
  { "Z" },
}
paths.p3 = { -- convex
  { "M", 313.57, 0 },
  { "L", 313.57, 130.3 },
  { "C", 313.57, 151.91, 295.32, 169.59, 273, 169.59 },
  { "L", 136.26, 169.59 },
  { "C", 113.95, 169.59, 95.69, 151.91, 95.69, 130.3 },
  { "L", 95.69, 0 },
  { "L", 313.57, 0 },
  { "Z" },
}
paths.p4 = { -- concave
  { "M", 560.33, 465.26 },
  { "L", 689.15, 465.26 },
  { "C", 710.17, 465.26, 727.37, 481.91, 727.37, 502.28 },
  { "L", 727.37, 600 },
  { "L", 522.1, 600 },
  { "L", 522.1, 502.28 },
  { "C", 522.1, 481.91, 539.3, 465.26, 560.33, 465.26 },
  { "Z" },
}
return function()
gfx.setColor(0.722, 0.788, 0.733, 1.000)
gfx.rectangle("fill", 0, 0, 1024, 600)

gfx.setColor(0.965, 0.690, 0.592, 1.000)
gfx.rectangle("fill", 0, 300, 1024, 300)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 383.76, 214.85, 161.43, 157.78, 30.06, 29.12)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
concave_fill(paths.p1)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 163.29, 519.81, 44.42, 43.41, 8.27, 8.01)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 129.78, 560.9, 26.29, 25.7, 4.9, 4.74)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 892.99, 377.57, 94.67, 92.53, 17.63, 17.07)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
convex_fill(paths.p2)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
convex_fill(paths.p3)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 17.38, 231.17, 36.93, 36.1, 6.88, 6.66)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 272.84, 407.19, 89.75, 87.72, 16.71, 16.19)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
gfx.rectangle("fill", 443.55, 39.22, 89.75, 87.72, 16.71, 16.19)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
gfx.rectangle("fill", 177.83, 271.17, 59, 57.66, 10.99, 10.64)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 635.83, 52.77, 161.75, 158.09, 30.12, 29.17)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
gfx.rectangle("fill", 854.51, 450.08, 26.29, 25.7, 4.9, 4.74)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 882.83, 484.96, 45.08, 44.06, 8.39, 8.13)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 879.52, 103.13, 45.08, 44.06, 8.39, 8.13)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
gfx.rectangle("fill", 927.72, 78.11, 25.15, 24.58, 4.68, 4.54)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 393.32, 126.04, 45.08, 44.06, 8.39, 8.13)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 417.66, 101.41, 16.11, 15.75, 3, 2.91)

gfx.setColor(0.804, 0.455, 0.451, 1.000)
gfx.rectangle("fill", 680.78, 276.21, 89.75, 87.72, 16.71, 16.19)

gfx.setColor(0.800, 0.439, 0.239, 1.000)
concave_fill(paths.p4)

end
