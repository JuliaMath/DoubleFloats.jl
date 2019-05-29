macro via_df64(fn, data)
    :( Float64.($(esc(fn)).(Double64.($(esc(data))))) )
end

macro via_df64(fn, xdata, ydata)
    :( Float64.($(esc(fn)).(Double64.($(esc(xdata))), Double64.($(esc(ydata))))) )
end

macro via_df32(fn, data)
    :( Float32.($(esc(fn)).(Double32.($(esc(data))))) )
end

macro via_df32(fn, xdata, ydata)
    :( Float32.($(esc(fn)).(Double32.($(esc(xdata))), Double32.($(esc(ydata))))) )
end
