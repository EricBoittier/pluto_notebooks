using Random
include("Game.jl")
include("Player.jl")
include("Card.jl")

using .Redacted

function create_game_from_cards(card_dicts::Vector{Dict{String, Any}}, player_names::Vector{String})
    # Create the game with a random seed
    seed = RandomDevice()()
    game = Game(seed)

    # Parse cards from dictionaries and add to the game's card pool
    for card_dict in card_dicts
        card = Card(
            card_dict["cost"],
            card_dict["cardType"]
        )
        card.lore = get(card_dict, "lore", 0)
        card.strength = get(card_dict, "strength", 0)
        card.willpower = get(card_dict, "willpower", 0)
        card.baseName = get(card_dict, "baseName", "")
        card.hasShift = get(card_dict, "hasShift", false)
        card.shiftValue = get(card_dict, "shiftValue", 0)
        card.inkable = get(card_dict, "inkable", false)
        push!(game.cards, card)
    end

    # Add players to the game
    for name in player_names
        add_player!(game, name)
    end

    # Start the game
    if !start_game!(game)
        error("Failed to start the game. Ensure the setup is correct.")
    end

    return game
end

# Example Usage
if abspath(PROGRAM_FILE) == @__FILE__
    card_dicts = [
        Dict("cost" => 1, "cardType" => :Location, "lore" => 2),
        Dict("cost" => 3, "cardType" => :Character, "strength" => 5, "willpower" => 3, "baseName" => "Warrior"),
        Dict("cost" => 2, "cardType" => :Character, "strength" => 2, "willpower" => 2, "baseName" => "Mage", "inkable" => true)
    ]

    player_names = ["Alice", "Bob"]

    game = create_game_from_cards(card_dicts, player_names)

    println("Game created successfully with players: ", join(map(p -> p.name, game.players), ", "))
end
