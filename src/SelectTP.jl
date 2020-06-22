module SelectTP

using Serialization, LinearAlgebra
using DungBase
using AbstractPlotting, GLMakie, MakieLayout, Colors

export selectTP

_cmap(t) = range(HSL(colorant"green"), stop = HSL(colorant"red"), length = length(t))

function selectTP(file = "data")
    data = deserialize(file)
    scene, layout = layoutscene()
    video = Node("a")
    # layout[1, 1] = LText(scene, video)#, tellheight = true)
    ax = layout[1, 1] = LAxis(scene, aspect = DataAspect(), title = video)
    track = Node(rand(DungBase.Point, 10))
    rawtrack = Node(rand(DungBase.Point, 10))
    feeder = Node(rand(DungBase.Point, 1))
    lines!(ax, track, color = map(_cmap, track))
    scatter!(ax, rawtrack, markersize = 6px, color = map(_cmap, rawtrack))
    scatter!(ax, feeder, color = :blue, markersize = 8px)
    tp1 = Node(rand(2))
    mousestate = addmousestate!(ax.scene)
    onmouseover(mousestate) do state
        tp1[] = state.pos
    end
    tp = map(tp1) do xy
        _, i = findmin(norm.(track[] .- Ref(xy)))
        i
    end
    tp2 = map(tp) do i
        track[][i:i]
    end
    scatter!(ax, tp2, color = RGBA(0,0,0,0.5), markersize = 10px)
    onmouseleftclick(mousestate) do state
        println(string(video[], ",", tp[]))
    end
    c = Condition()
    h = layout[2,1] = LButton(scene, label = "Next!", tellwidth = false)
    on(h.clicks) do _
        notify(c)
    end
    for (k, v) in data
        @info "doing experiment: $k"
        for r in v.runs
            track[] = r.data.track.coords
            rawtrack[] = r.data.track.rawcoords.xy
            feeder[] = [r.data.feeder]
            video[] = r.metadata.comment
            display(scene)
            autolimits!(ax)
            wait(c)
        end
    end
    GLMakie.destroy!(display(scene))
    @info "Finished!!!"
end

end
