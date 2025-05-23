# FUNCTIONS USED TO SIMULATE HABITAT DESTRUCTION

# RANDOM(Uncorrelated) HABITAT DESTRUCTION
#spatially uncorrelated destruction
function habitat_destruction_random(dn, x_state, x_r, x_c)
        
    # pristine patches
    p_pristine = findall(x_state.==1)

    # select dn pristine patches at random and change their state to 0 (destroyed)
    patch_d = sample(p_pristine, dn, replace=false)
    x_state[patch_d] .= 0

    # species in destroyed patches become extinct
    x_r = x_r .* x_state
    x_c = x_c .* x_state

	return x_state, x_r, x_c
end


# NONRANDOM(Corrrelated) HABITAT DESTRUCTION
# spatially correlated destruction
function habitat_destruction_nonrandom(dn, n_patch, x_state, x_r, x_c, k,M_adj)
        
    if k==1  # first destruction step - destroy 1% patches at random first
        # pristine patches
        p_pristine = findall(x_state.==1)

        # select 1% pristine patches at random and change their state to 0 (destroyed)
        dn_k = floor(Int, 0.01*n_patch)
        patch_d = sample(p_pristine, dn_k, replace=false)
        x_state[patch_d] .= 0

        # number of remaining "to be destroyed" patches
        n_d = dn - dn_k

    else  # other destruction steps - destroy dn patches
        n_d = dn
    end

    # destroyed patches
    p_destroyed = findall(x_state.==0)

    # find neighbours of destroyed patches
    destroyed_neigh = findall(sum(M_adj[p_destroyed,:], dims=1)[1,:] .> 0)

    # pristine patches
    p_pristine = findall(x_state.==1)

    # neighbours of destroyed patches that are pristine
    neigh_pristine = intersect(destroyed_neigh, p_pristine)

    if length(neigh_pristine)>n_d
        # number of destroyed neighbours of pristine patches
        n_conn = sum(M_adj[p_destroyed,neigh_pristine], dims=1)[1,:]

        # select n_d patches at random and change their state to 0 (destroyed)
        # sampling probability weighted by number of destroyed neighbours
        patch_d = sample(neigh_pristine, Weights(n_conn), n_d, replace=false)
        x_state[patch_d] .= 0
    
    else
        # select all patches and change their state to 0 (destroyed)
        x_state[neigh_pristine] .= 0
    
        if length(neigh_pristine)<n_d
            # number of remaining "to be destroyed" patches
            n_d = n_d - length(neigh_pristine)

            # pristine patches
            p_pristine = findall(x_state.==1)

            # select n_d patches at random and change their state to 0 (destroyed)
            patch_d = sample(p_pristine, n_d, replace=false)
            x_state[patch_d] .= 0

        end
    end

     # species in destroyed patches become extinct
     x_r = x_r .* x_state
     x_c = x_c .* x_state

	return x_state, x_r, x_c
end



