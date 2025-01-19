module LibraryC

using Distributions
using Combinatorics
using CSV
using JSON
using Random
using PlutoUI
using Images
using Plots
using PlotThemes
using StatsPlots 
using ImageView
using MosaicViews
using DataFrames

Plots.theme(:dark)

function ClipName(s::String)
    return s[3:length(s)]
end

function GetCount(s::String)
    return parse(Int64, s[1])
end 

function FindCard(s::String)
    c = copy(cards_json)
    for item in c
        if item["Name"] == s
            println(item["Name"])
            return item
        end
    end
    throw("Could not find card: $s")
end

function CreateDeck(cards::Vector, counts::Vector, count::Int)
    
    d = Vector{Dict}()
    println()
    for i in range(1, length=length(cards))
        for _ in range(1, length=counts[i])
            println(cards[i])
            push!(d, cards[i])
        end
    end
    return d
end

function LoadIm(card)
    return load(card["Image"])
end

function LoadImages(df)
    images = [load(c) for c in df[!,"Image"]]
    return images
end


# define the data dir.
redacted_path::String = "data"
# load all the card data
cards_path = joinpath(redacted_path, "cards.json")
cards_json = JSON.parsefile(cards_path)
# load the decklist
decklist_path = joinpath(redacted_path, "decklist.txt")
# open(decklist_path) do f
#   # line_number
#   line = 0  
#   # read till end of file
#   while ! eof(f)  
#      # read a new / next line for every iteration           
#      s = readline(f)          
#      line += 1
#      # println("$line . $s")
#   end
# end
# create the deck list
deck_requirements::Vector{String} = readlines(open(decklist_path), keep = false)

	

deck_card_names = map(ClipName, deck_requirements)
deck_card_counts = map(GetCount, deck_requirements)
deck_count = cumsum(deck_card_counts)[length(deck_requirements)]
deck_cards_json = map(FindCard, deck_card_names)
deck_json = CreateDeck(deck_cards_json, deck_card_counts, deck_count)
sort(collect(deck_json), by=x->x["Cost"]+x["Card_Num"]/100)
deck_dataframe = DataFrame(Tables.dictcolumntable(deck_json))

# 	all_images = LoadImages(deck_dataframe)
# 	mosaicview(all_images, nrow=10, npad=1, rowmajor=true)

# deck_cards_json_df = DataFrame(Tables.dictcolumntable(deck_cards_json))
# name_to_image = Dict()
# for (c, i) in zip(deck_cards_json_df.Name, deck_cards_json_df.Image)
#     name_to_image[c] = load(i)
# end


# draw = shuffle(1:nrow(deck_dataframe))[1:7];
# print(draw)
# df = deck_dataframe[draw, :]
# images = [name_to_image[n] for n in df.Name] #LoadImages(deck_dataframe[draw, :])
# images_small = [imresize(x, (300, 180)) for x in images];
# mosaicview(images_small, nrow=1, npad=1, rowmajor=true)


# colors = get_color_palette(:auto, plot_color(:white));
 
# inks = [c["Cost"] for c in deck_json];
# inkables = [c["Inkable"] ? 1 : 0 for c in deck_json];
# willpower = ["Willpower" in keys(c) ? c["Willpower"] : nothing for c in deck_json];
# strength = ["Strength" in keys(c) ? c["Strength"] : nothing for c in deck_json];

# p1 = histogram(deck_dataframe[!,"Cost"], label="Costs", bins=10,
#     # normalize=:pdf, 
#     color=colors[1],
#     )
# p2 = histogram(deck_dataframe[!,"Inkable"], label="Inkables", bins=10, 
#     normalize=:pdf, 
#     color=colors[2],
#     )
# p3 = histogram(deck_dataframe[!,"Strength"], label="Strength", bins=10,
#     # normalize=:pdf, 
#     color=colors[3],
#     )
# p4 = histogram(deck_dataframe[!,"Willpower"], label="Willpower", bins=10,
#     # normalize=:pdf, 
#     color=colors[4],
#     )
# l = @layout [a b ; c d]

# plot(p1, p2, p3, p4, layout = l);

	
# Plots.theme(:dark)
# mix = shuffle(1:nrow(deck_dataframe))
# cs = cumsum(deck_dataframe[!,"Inkable"][mix])
# n_cards_till_max_cost = findall(x->x>=maximum(deck_dataframe[!,"Cost"]), cs)
# plot(deck_dataframe[!,"Cost"][mix], 
#     label="Cost",
#     m=deck_dataframe[!,"Inkable"][mix],
#     s=:dash,
#     marker_colors=deck_dataframe[!,"Inkable"][mix],
# )
# plot!(twinx(), cs, color=colors[3], label="Ink")
# vline!([n_cards_till_max_cost[1]], label="Max Single Cost Reached")
# vline!([7.1], label="Starting Hand")
# vline!([14.1], label="Mulligan")

end
