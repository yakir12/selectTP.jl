module SelectTP

using Serialization, LinearAlgebra
using DungBase
using AbstractPlotting, GLMakie, MakieLayout, Colors

export selectTP

function selectTP(file = "data")
    data = deserialize(file)
    scene, layout = layoutscene()
    ax = layout[1, 1] = LAxis(scene, aspect = DataAspect())
    track = Node(rand(DungBase.Point, 10))
    feeder = Node(rand(DungBase.Point, 1))
    lines!(ax, track)
    scatter!(ax, feeder, color = :green, markersize = 8px)
    tp1 = Node(rand(2))
    mousestate = addmousestate!(ax.scene)
    onmouseover(mousestate) do state
        tp1[] = state.pos
        autolimits!(ax)
    end
    tp = map(tp1) do xy
        _, i = findmin(norm.(track[] .- Ref(xy)))
        i
    end
    tp2 = map(tp) do i
        [track[][i]]
    end
    scatter!(ax, tp2, color = RGBA(1,0,0,0.5), markersize = 10px)
    video = Node("")
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
            feeder[] = [r.data.feeder]
            video[] = r.metadata.comment
            display(scene)
            wait(c)
        end
    end
end

end
