# Draw sequence of dots as circles connected by arrows without overlap

using LinearAlgebra, Plots; gr(legend=false)

# as: arrow head size 0-1 (fraction of arrow length; if <0 : use quiver with default constant size
# la: arrow alpha transparency 0-1
function arrow0!(x, y, u, v; as=0.07, lc=:black, la=1)  # by @rafael.guerra
    if as < 0
        quiver!([x],[y],quiver=([u],[v]), lc=lc, la=la)  # NB: better use quiver directly in vectorial mode
    else
        nuv = sqrt(u^2 + v^2)
        v1, v2 = [u;v] / nuv,  [-v;u] / nuv
        v4 = (3*v1 + v2)/3.1623  # sqrt(10) to get unit vector
        v5 = v4 - 2*(v4'*v2)*v2
        v4, v5 = as*nuv*v4, as*nuv*v5
        plot!([x,x+u], [y,y+v], lc=lc,la=la)
        plot!([x+u,x+u-v5[1]], [y+v,y+v-v5[2]], lc=lc, la=la)
        plot!([x+u,x+u-v4[1]], [y+v,y+v-v4[2]], lc=lc, la=la)
    end
end

function circleShape(x,y,r)   # by @lazarusA
    θ = LinRange(0,2π,72)
    x .+ r*sin.(θ), y .+ r*cos.(θ)
end

# support points (x,y) sorted in desired plotting order
x, y = [0.5, 1.],  [15., 1.0]
# compute full-length connecting vectors
u, v = diff(x), diff(y)

# define circle radius in plot units
cr = 0.25

# recompute vector lengths to not overlap the circles
lv = [norm([u,v]) for (u,v) in zip(u,v)]
lv0 = lv .- 2*cr
u0, v0 = u .* lv0./lv,  v .* lv0./lv

# recompute support points to start after circle
x0, y0 = x[1:end-1] .+ cr*u./lv,  y[1:end-1] .+ cr*v./lv

# plot data
plot()
for (x,y) in zip(x,y)
   display(plot!(circleShape(x,y,cr),seriestype=:shape,c=:blue,lw=0.1,lc=:blue,ratio=1,fill_alpha=0.5))
end
for (x,y,u,v) in zip(x0,y0,u0,v0)
    display(arrow0!(x, y, u, v; as=-0.07, lc=:blue, la=1)) # if as > 0, variable arrow head sizes
end