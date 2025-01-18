function plot_ramp(deck_dataframe::DataFrame)
	Plots.theme(:dark)
	mix = shuffle(1:nrow(deck_dataframe))
	cs = cumsum(deck_dataframe[!,"Inkable"][mix])
	n_cards_till_max_cost = findall(x->x>=maximum(deck_dataframe[!,"Cost"]), cs)
	
	plot(deck_dataframe[!,"Cost"][mix], 
		label="Cost",
		m=deck_dataframe[!,"Inkable"][mix],
		s=:dash,
		marker_colors=deck_dataframe[!,"Inkable"][mix],
	)

	plot!(twinx(), cs, color=colors[3], label="Ink")
	
	vline!([n_cards_till_max_cost[1]], label="Max Single Cost Reached")
	vline!([7.1], label="Starting Hand")
	vline!([14.1], label="Mulligan")
end

function plot_deck(deck_dataframe::DataFrame)
	p1 = histogram(deck_dataframe[!,"Cost"], label="Costs", bins=10,
		# normalize=:pdf, 
		color=colors[1],
		)
	p2 = histogram(deck_dataframe[!,"Inkable"], label="Inkables", bins=10, 
		normalize=:pdf, 
		color=colors[2],
		)
	p3 = histogram(deck_dataframe[!,"Strength"], label="Strength", bins=10,
		# normalize=:pdf, 
		color=colors[3],
		)
	p4 = histogram(deck_dataframe[!,"Willpower"], label="Willpower", bins=10,
		# normalize=:pdf, 
		color=colors[4],
		)
	l = @layout [a b ; c d]

	plot(p1, p2, p3, p4, layout = l);
end