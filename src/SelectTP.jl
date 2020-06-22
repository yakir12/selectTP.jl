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
    rawtrack = Node(rand(DungBase.Point, 10))
    feeder = Node(rand(DungBase.Point, 1))
    lines!(ax, track)
    lines!(ax, rawtrack, color = RGBA(0,1,0,0.5))
    scatter!(ax, feeder, color = :green, markersize = 8px)
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
            rawtrack[] = r.data.track.rawcoords
            feeder[] = [r.data.feeder]
            video[] = r.metadata.comment
            display(scene)
            autolimits!(ax)
            wait(c)
        end
    end
    @warn "Finished!!!"
end

end
