function get_spatial_network(spatialNetwork)

	# import spatial netork graph
	g = loadgraph(string("../../Data/spatial_networks/Madj_",spatialNetwork,"_r1.lgz"))

	# convert to adjacency matrix
	M_adj = adjacency_matrix(g)

	# number of patches
	n_patch = size(M_adj, 1)

	# return
	return M_adj, n_patch
end


function get_interaction_network(interactionNetwork)

	# get network incidence matrix
	M_inc = readdlm(string("../../Data/interaction_networks/Minc_",interactionNetwork,".csv"), ' ', Int)

	# number of resources
	n_r = size(M_inc, 1)

	# number of consumers
	n_c = size(M_inc, 2)

	# return
	return M_inc, n_r, n_c
end


function setup_grids(n_patch, n_r, n_c)

	# vector of patch states (1=pristine, 0=destroyed)
	x_state = ones(Int, n_patch)

	# grid of resources (1=present, 0=absent) for each species
	x_r = ones(Int, n_patch, n_r)

	# grid of consumers (1=present, 0=absent) for each species
	x_c = ones(Int, n_patch, n_c)

	# return
	return x_state, x_r, x_c
end


function setup_habitat_destruction(dD, n_patch)

	# number of patches destroyed in a step
	dn = floor(Int, dD*n_patch)

	# vector of number of destroyed patches
	d = collect(0:dn:n_patch)

	# vector of fraction of destroyed patches
	D = d/n_patch

	# return
	return dn, D
end


function initialise_dataframes_store_results(tmax, D, n)

	# initialise dataframes for storing results
	df_dt = DataFrame(D = repeat(D, inner=100*n),
					  t = repeat((tmax+1-100):tmax, outer=length(D), inner=n),
	                  species = repeat(1:n, outer=length(D)*100),
					  abundance = Vector{Union{Missing, Float32}}(missing, length(D)*100*n))

	#df_dt[(df_dt.D.==0) .& (df_dt.t.==1),"abundance"] .= 1

	# return
	return df_dt

end


#function initialise_dataframes_store_results(tmax, D, n)
    # Determine the number of time points to store (last 200)
 #   max_time_points = min(tmax, 200)

    # Initialise dataframes for storing results
  #  df_dt = DataFrame(
   #     D = repeat(D, inner=max_time_points*n),
    #    t = repeat((tmax-max_time_points+1):tmax, outer=length(D), inner=n),
     #   species = repeat(1:n, outer=length(D)*max_time_points),
      #  abundance = Vector{Union{Missing, Float32}}(missing, length(D)*max_time_points*n)
    #)

    # Set abundance at the initial time point for D == 0
    #df_dt[(df_dt.D .== 0) .& (df_dt.t .== (tmax-max_time_points+1)), "abundance"] .= 1

    # Return the dataframe with the last 200 time points stored
    #return df_dt
#end




