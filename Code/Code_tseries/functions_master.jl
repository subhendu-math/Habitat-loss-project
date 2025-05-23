function find_neighborhood(M_adj, i)

  # find patches connected to patch i
  neigh = findall(M_adj[i,:].==1)

  return neigh
end


function update_patches_sequentially(n_patch, M_adj, M_inc, n_r, n_c, e_r, e_c, c_r, c_c, x_r, x_c, x_r_old, x_c_old, x_state)

  # update each patch sequentially
  for i = 1:n_patch

    # check state of the current patch
		if x_state[i] == 0
			# if patch is destroyed, move to next patch
			continue
		end

    # find patch neighbourhood
    neigh = find_neighborhood(M_adj, i)

    # resource extinctions and colonisations (see functions_extinction_colonisation_mutualistic/antagonistic)
    x_r = resource_extinctions_and_colonisations(n_r, e_r, c_r, x_r, x_r_old, x_c_old, M_inc, neigh, i)

    # consumer extinctions and colonisations (see functions_extinction_colonisation_mutualistic/antagonistic)
    x_c = consumer_extinctions_and_colonisations(n_c, e_c, c_c, x_c, x_r_old, x_c_old, M_inc, neigh, i)
      
  end # i loop
  
  return x_r, x_c
end


function calculate_global_abundance_and_store(x, n_patch, df_dt, D_current, g)

	# calculate global abundance
	ab = transpose(sum(x, dims=1) ./ n_patch)

	# store results
	df_dt[(df_dt.D.==D_current) .& (df_dt.t.==g),["abundance"]] .= ab

	return df_dt
end


function iterate_model_through_time(tmax, x_state, x_r, x_c, n_patch, M_adj, M_inc, n_r, n_c, e_r, e_c, c_r, c_c, df_dt_r, df_dt_c, D_current)

  # iterate until tmax
  for g = 2:tmax
    
    # make copies of occupancy and trait arrays
    x_r_old = copy(x_r)
    x_c_old = copy(x_c)

    # update each patch sequentially
    x_r, x_c = update_patches_sequentially(n_patch, M_adj, M_inc, n_r, n_c, e_r, e_c, c_r, c_c, x_r, x_c, x_r_old, x_c_old, x_state)

    if g > (tmax-100) # final 100 timesteps
      # calculate global abundance and store results
      df_dt_r = calculate_global_abundance_and_store(x_r, n_patch, df_dt_r, D_current, g)
      df_dt_c = calculate_global_abundance_and_store(x_c, n_patch, df_dt_c, D_current, g)
    end

  end # g loop

  # combine global abundance dataframes
  df_dt_r[:,"guild"] .= "resources"
  df_dt_c[:,"guild"] .= "consumers"
  df_dt = vcat(df_dt_r, df_dt_c)
  
  return x_r, x_c, df_dt
end


function dynamics(spatialNetwork, interactionNetwork, destruction, tmax, dD, e_r, e_c, c_r, c_c, replicate)

    # get spatial network adjacency matrix and number of patches (see functions_setup)
    M_adj, n_patch = get_spatial_network(spatialNetwork)

    # setup variables for habitat destruction
    dn, D = setup_habitat_destruction(dD, n_patch)

    # get interaction network incidence matrix, 
    # number of resources and number of consumers (see functions_setup)
    M_inc, n_r, n_c = get_interaction_network(interactionNetwork)

    # setup initial patch occupancy and traits (x - species presencce/absence)
    # (see functions_setup)
    x_state, x_r, x_c = setup_grids(n_patch, n_r, n_c)

    # setup dataframe for storing transient results (see funtions_setup)
    df_dt_r = initialise_dataframes_store_results(tmax, D, n_r)  # resources
    df_dt_c = initialise_dataframes_store_results(tmax, D, n_c)  # consumers
    df_dt = DataFrame(D=Float32[], t=Int[], species=Int[], abundance=Float32[], guild=String[])

    # loop through habitat destruction fractions
    for k=1:length(D)

      # current D
      D_current = D[k]
      
      # iterate colonisation/extinction and coevolution dynamics through timesteps
      x_r, x_c, df_dt = iterate_model_through_time(tmax, x_state, x_r, x_c, n_patch, M_adj, M_inc, n_r, n_c, e_r, e_c, c_r, c_c, df_dt_r, df_dt_c, D_current)

      if k < length(D)
        # set seed
        Random.seed!(replicate*k)
        # habitat destruction
        if destruction == "random"
          x_state, x_r, x_c = habitat_destruction_random(dn, x_state, x_r, x_c)
        elseif destruction == "nonrandom"
          x_state, x_r, x_c = habitat_destruction_nonrandom(dn, n_patch, x_state, x_r, x_c, k,M_adj)
        end
      end

    end # k loop

  return df_dt
end