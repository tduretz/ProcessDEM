using GeoMakie, GLMakie, Rasters, ArchGDAL, MathTeXEngine#, DataFrames, CSV, ProgressMeter, Printf, MAT, Plots
# using BSON: @load
Makie.update_theme!(fonts = (regular = texfont(), bold = texfont(:bold), italic = texfont(:italic)))
using WhereTheWaterFlows
const WWF = WhereTheWaterFlows

norm_cat = false

function PreProcess( DEM )
    h    = Float32.(DEM.data[:,:,1])::Matrix{Float32}
    h   .= h[:,end:-1:1]
    println(typeof(h))
    println(DEM.missingval)
    h[h.==DEM.missingval] .= NaN
    return h
end

function ReadDEM()
   
    # Load geotiffs
    DEM              = Raster("data/MontBlanc.tif")
    # dist_roads       = Raster("data/dist_roads.tif")
    # plan_curvature   = Raster("data/plan_curvature.tif")
    # profil_curvature = Raster("data/profil_curvature.tif")
    # Slope            = Raster("data/Slope.tif")
    # TWI              = Raster("data/TWI.tif")
    # Geology          = Raster("data/Geology.tif")
    # LandCover        = Raster("data/LandCover.tif")

    x    = Array(DEM.dims[1])
    y    = Array(DEM.dims[2])
    y    = y[end:-1:1] 
    h              = PreProcess(DEM)
    h_rev = .-copy(h)
    @show size(x)
    @show size(y)
    @show size(h)

    wf = waterflows(h)                        #area, slen, dir, nout, nin, pits, c, bnds
    area1, slen1, dir1, nout1, nin1, pits1, c1, bnds1 = waterflows(h_rev)
   
    h_rev_filled = fill_dem(h_rev, pits1, dir1)

    fig = Figure()
    #########################################################
    ax1  = GeoAxis(fig[1, 1], 
        xlabel = L"Longitude [$\degree$]", 
        ylabel = L"Latitute [$\degree$]", 
        lonlims = (minimum(x), maximum(x)), 
        latlims = (minimum(y), maximum(y)),
        xlabelsize=20, ylabelsize=20, xticklabelsize=20, yticklabelsize=20
        )
    ax1.aspect = 1/((x[2]-x[1])/ (y[2]-y[1]))
    # hm = heatmap!(ax, x, y, h)
    hm = image!(ax1, x, y, h, colormap=:haline)
    # hm = surface!(ax, x, y, h, colormap=:terrain)
    GLMakie.Colorbar(fig[1, 2], hm, label = L"$$Stream length [m]", width = 20, labelsize = 25, ticklabelsize = 14 )
    GLMakie.colgap!(fig.layout, 20)
    #########################################################
    ax2  = GeoAxis(fig[2, 1], 
    xlabel = L"Longitude [$\degree$]", 
    ylabel = L"Latitute [$\degree$]", 
    lonlims = (minimum(x), maximum(x)), 
    latlims = (minimum(y), maximum(y)),
    xlabelsize=20, ylabelsize=20, xticklabelsize=20, yticklabelsize=20
    )
    ax2.aspect = 1/((x[2]-x[1])/ (y[2]-y[1]))
    # hm = heatmap!(ax, x, y, h)
    hm = image!(ax2, x, y, h_rev_filled.-h_rev, colormap=:haline)
    # hm = surface!(ax, x, y, h, colormap=:terrain)
    GLMakie.Colorbar(fig[2, 2], hm, label = L"$$Stream length [m]", width = 20, labelsize = 25, ticklabelsize = 14 )
    GLMakie.colgap!(fig.layout, 20)
    #########################################################
    DataInspector(fig)
    display(fig)

end

ReadDEM()

# function otherMWE()
# fig = Figure(resolution = (800, 800))

# for i in 1:2, j in 1:2
#     # otherwise the 0.7 tick label is missing
#     xticks_values = [0.5, 0.55, 0.6, 0.65, 0.7]
#     # no %g equivalent yet
#     xticks_strings = ["0.5", "0.55", "0.6", "0.65", "0.7"]
#     # between 0 (no shift) and 0.5 (justified)
#     xticklabel_relative_shift = 0.3
#     N_xticklabel = length(xticks_values)
#     xticklabel_halign = fill(0.5, N_xticklabel)
#     xticklabel_halign[begin] -= xticklabel_relative_shift
#     xticklabel_halign[end] += xticklabel_relative_shift
#     xticklabel_valign = fill(i == 1 ? :bottom : :top, N_xticklabel)
#     xticklabelalign = collect(zip(xticklabel_halign, xticklabel_valign))
#     Axis(fig[i, j];
#         limits = (0.5, 0.7, -2, 2),
#         xticks = (xticks_values, xticks_strings),
#         # xticklabelalign,
#         xaxisposition = (i == 1 ? :top : :bottom),
#         yaxisposition = (j == 1 ? :left : :right)
#     )
# end
# colgap!(fig.layout, 25)
# rowgap!(fig.layout, 25)
#     display(fig)
# end

# otherMWE()

# using GeoMakie
# function MWE()
#     x = LinRange(44., 48., 100)
#     y = LinRange( 7.,  8., 100)
#     fig = Figure()
#     ax  = GeoAxis(fig[1, 1], 
#         xlabel = L"Longitude [$\degree$]", 
#         ylabel = L"Latitute [$\degree$]", 
#         lonlims = (minimum(x), maximum(x)), 
#         latlims = (minimum(y), maximum(y)),
#         xlabelsize=20, ylabelsize=20, xticklabelsize=20, yticklabelsize=20
#         )
#     image!(ax, x, y, zeros(length(x), length(y)))
#     ax.aspect = ((x[end]-x[begin])/ (y[end]-y[begin]))
#     display(fig)
# end
# MWE()
