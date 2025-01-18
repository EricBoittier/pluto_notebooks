module GameScriptJL
using Random
include("Game.jl")
include("Player.jl")

using .Redacted
import .Redacted.Card as Card
import .Redacted.Game as Game
import .Redacted.Player as Player

function create_game_from_cards(players_card_dicts::Vector{Vector{Dict}}, player_names::Vector{String})
    # Create the game with a random seed
    seed = rand(Int)
    # rng = MersenneTwister(seed)
    game = Game(seed)
    Decks = Vector{Vector{Card}}() #(length(players_card_dicts))
    

    for card_dicts in players_card_dicts
        tmp_deck = Vector{Card}() #(length(card_dicts))
        # Parse cards from dictionaries and add to the game's card pool
        for card_dict in card_dicts
            card = Card(
                card_dict
            )
            card.lore = get(card_dict, "lore", 0)
            card.strength = get(card_dict, "strength", 0)
            card.willpower = get(card_dict, "willpower", 0)
            card.baseName = get(card_dict, "baseName", "")
            card.hasShift = get(card_dict, "hasShift", false)
            card.shiftValue = get(card_dict, "shiftValue", 0)
            card.inkable = get(card_dict, "inkable", false)
            push!(game.cards, card)
            push!(tmp_deck, card)
        end
        push!(Decks, tmp_deck)
    end

    println(Decks)

    # Add players to the game
    for (name, deck) in zip(player_names, Decks)
        println("Adding player ", name)
        
        if any(p -> p.name == name, game.players)
            println("Player name $name already exists.")
        else
            println(typeof(deck))
            println(typeof(deck[1]))
            
            push!(game.players, Player(name, convert(Int64,length(game.players) + 1), deck))
        end
    end

    # Start the game
    game->start_game!(game)

    return game
end

# Example Usage
if abspath(PROGRAM_FILE) == @__FILE__
    player_names = ["Alice", "Bob"]
    game = create_game_from_cards(card_dicts, player_names)
    println("Game created successfully with players: ", join(map(p -> p.name, game.players), ", "))
    println("Game has ", length(game.cards), " cards in the card pool.")   
    println("Game has ", length(game.players), " players.")
    println("Game has ", length(game.currentPlayer.hand), " cards in the current player's hand.")
    println("Game has ", length(game.currentPlayer.deck), " cards in the current player's deck.")
end

end