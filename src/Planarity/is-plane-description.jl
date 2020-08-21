using LightGraphs

"""
    is_plane_description(g, description)

Returns `true` if the given combinatorial description of graph `g` is plane.

The algorithm requires the graph `g` to be simple and undirected.

A drawing of a planar graph induces a cyclic clockwise order in the neighbors of each vertex.
A list of these cyclic orders is called a combinatorial description of the drawing.
A facial cycle of a combinatorial description D is a cycle (v_0,v_1,...,v_k,v_0) where v_i+1 succeeds v_i-1 in the list D(v_i).
A combinatorial description of a plane graph is also called plane.
Clearly, every planar graph has a combinatorial description which is plane.
This algorithm is correct because of the following theorem:
    A combinatorial description D of a drawing of a graph G is plane
        if and only if
    nv(G) - ne(G) + fD = 2, where fD is the number of facial cycles of description D.

This algorithm is presented in the dissertation available at https://www.ime.usp.br/~coelho/sh/index.html.
"""

function is_plane_description end

function is_plane_description(g::SG,
                    description::Vector{Vector{T}}) where 
                    {T <: Integer, SG <: SimpleGraph{T}}

    nvg = nv(g)
    neg = ne(g)
    neg_diff = zero(Int)

    for e in edges(g)
        if src(e) != dst(e)
            neg_diff +=1 
        end
    end

    loops = neg - neg_diff
    nvg >= 3 && neg_diff > 3*nvg - 6 && return false

    # the direction is important due to the clockwise description, so the second copy is reversed
    # in(e, used) indicates if edge e has been used in a facial cycle
    used = Set{edgetype(g)}()
    faces = zero(T)
    
    # counting facial cycles
    for e in edges(g)
        e1 = nothing
        start = nothing

        if !in(e, used)
            e1 = e
            start = e
        elseif !in(reverse(e), used)
            e1 = reverse(e)
            start = reverse(e)
        end

        if e1 !== nothing
            while true
                push!(used, e1)
                # we find the successor of src(e1) in the list of dst(e1)
                u, v = src(e1), dst(e1)
                v_list = description[v]
                u_index = findfirst(x -> x == u, v_list)

                if u_index == length(v_list) 
                    e1 = Edge(v, first(v_list)) 
                else 
                    e1 = Edge(v, v_list[u_index + 1])
                end             
                e1 == start && break
            end
            faces += 1
        end
    end
    # using Euler's formula
    return faces + loops == neg - nvg + 2
end