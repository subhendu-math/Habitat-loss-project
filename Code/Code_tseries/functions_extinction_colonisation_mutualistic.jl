# RESOURCE FUNCTIONS

function resource_extinctions(n_r, e_r, x_r, i)

    # extinct species (if random number < extinction probability)
    sp_ext = findall(rand(n_r) .< e_r)

    # update species presence
    x_r[i,sp_ext] .= 0

	return x_r
end


function get_consumer_partners(M_inc, h)

	# find consumer partners of resource h
	c_part = findall(M_inc[h,:].==1)

	return c_part

end


function compute_resource_colonisation_prob(pc_r, c_part_sp, c_r)

	j_count = 0

	for l = c_part_sp

		j_count = j_count+1
		prod = 1 - c_r / j_count
		pc_r = pc_r * prod

	end

	return pc_r
end


function resource_colonisation_prob(neigh, x_r_old, x_c_old, x_r, c_part, c_r, i, h)

	# initialise "not colonised" probability
	pc_r = 1

    # check neighbours
    for f = neigh

        # if resource h absent from neighbouring patch -> skip
    	if x_r_old[f,h] == 0
    		continue

    	# if resource h present in neighbouring patch
		else

			# consumers present in neighbouring patch
			c_neigh_all = findall(x_c_old[f,:].==1)

			# consumer partners present in neighbouring patch
			c_part_sp = c_neigh_all[findall(x-> x in c_part, c_neigh_all)]

			# compute "not colonised" probability
			if length(c_part_sp) != 0 # if resource h and its partner(s) present in neighbouring patch

				pc_r = compute_resource_colonisation_prob(pc_r, c_part_sp, c_r)

			end

    	end

    end # f loop

	# colonisation if random number > "not colonised" probability
	if rand() > pc_r
		x_r[i,h] = 1
	end

    return x_r
end


function resource_colonisations(M_inc, neigh, x_r_old, x_c_old, x_r, c_r, i, h)

    # find consumer partners of resource h
	c_part = get_consumer_partners(M_inc, h)

    # compute colonisation probability, update occupancy array
	x_r = resource_colonisation_prob(neigh, x_r_old, x_c_old, x_r, c_part, c_r, i, h)

    return x_r
end


function resource_extinctions_and_colonisations(n_r, e_r, c_r, x_r, x_r_old, x_c_old, M_inc, neigh, i)

    # resource extinctions
    x_r = resource_extinctions(n_r, e_r, x_r, i)

    # resources absent from patch i
    sp_absent = findall(x_r_old[i,:] .== 0)
    
    # resource colonisations - loop through absent resources
    for h = sp_absent

        # resource colonisations
        x_r = resource_colonisations(M_inc, neigh, x_r_old, x_c_old, x_r, c_r, i, h)

    end

	return x_r
end


# CONSUMER FUNCTIONS

function consumer_extinctions(n_c, e_c, x_c, i)

    # extinct species (if random number < extinction probability)
    sp_ext = findall(rand(n_c) .< e_c)

    # update species presence and traits
    x_c[i,sp_ext] .= 0

	return x_c
end


function get_resource_partners(M_inc, x_r_old, i, h)

	# find resource partners of consumer h
	r_part = findall(M_inc[:,h].==1)

	# find resources present in current patch
	r_patch_all = findall(x_r_old[i,:].==1)

	# find resource partners present in current patch
	r_part_sp = r_patch_all[findall(x-> x in r_part, r_patch_all)]

	return r_part_sp
end


function compute_consumer_colonisation_prob(pc_c, c_c, r_part_sp)

	i_count = 0

	for m = r_part_sp

		i_count = i_count+1
		prod = 1 - c_c / i_count
		pc_c = pc_c * prod

	end # m loop

	# return
	return pc_c
end


function consumer_colonisation_prob(x_c, x_c_old, r_part_sp, neigh, c_c, i, h)

	# initialise "not colonised" probability
	pc_c = 1

    # check neighbours
	for f = neigh

        # if consumer h absent from neighbouring patch -> skip
		if x_c_old[f,h] == 0
			continue

		# if consumer h present in neighbouring patch
		else

			# compute "not colonised" probability
			pc_c = compute_consumer_colonisation_prob(pc_c, c_c, r_part_sp)

		end

	end # f loop

	# colonisation if random number > "not colonised" probability
	if rand() > pc_c
		x_c[i,h] = 1
	end

	return x_c

end


function consumer_colonisations(M_inc, x_c, x_r_old, x_c_old, neigh, c_c, i, h)

	# find resource partners of consumer h
	r_part_sp = get_resource_partners(M_inc, x_r_old, i, h)

	# check neighbours
	# if at least one plant partner present in current patch
	if length(r_part_sp) > 0
		x_c = consumer_colonisation_prob(x_c, x_c_old, r_part_sp, neigh, c_c, i, h)
	end

	return x_c
end


function consumer_extinctions_and_colonisations(n_c, e_c, c_c, x_c, x_r_old, x_c_old, M_inc, neigh, i)

    # consumer extinctions
    x_c = consumer_extinctions(n_c, e_c, x_c, i)

    # consumers absent from patch i
    sp_absent = findall(x_c_old[i,:] .== 0)

	# consumer colonisations - loop through absent consumers
	for h = sp_absent

    	# consumer colonisations
        x_c = consumer_colonisations(M_inc, x_c, x_r_old, x_c_old, neigh, c_c, i, h)

    end

	return x_c
end