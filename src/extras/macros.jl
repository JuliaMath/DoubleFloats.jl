via_df64(fn::F, data) where {F<:Function} = Float64.( fn( Double64.(data) ) )
dot_df64(fn::F, data) where {F<:Function} = Float64.( fn.( Double64.(data) ) )

via_df64(fn::F, data1, data2) where {F<:Function} = Float64.( fn(  Double64.(data1), Double64.(data2) ) )
dot_df64(fn::F, data1, data2) where {F<:Function} = Float64.( fn.( Double64.(data1), Double64.(data2) ) )

via_df64(fn1::F1, fn2::F2, data) where {F1<:Function, F2<:Function} = Float64.( fn1( fn2(  Double64.(data) ) ))
dot_df64(fn1::F1, fn2::F2, data) where {F1<:Function, F2<:Function} = Float64.( fn1.( fn2.( Double64.(data) ) ))

via_df64(fn1::F1, fn2::F2, data1, data2) where {F1<:Function, F2<:Function} = Float64.( fn1( fn2(  Double64.(data1), Double64.(data2) ) ))
dot_df64(fn1::F1, fn2::F2, data1, data2) where {F1<:Function, F2<:Function} = Float64.( fn1.( fn2.( Double64.(data1), Double64.(data2) ) ))

macro via_df64(fn, data)
    :( Float64.($(esc(fn)).(Double64.($(esc(data))) )) )
end

macro via_df64(fn, xdata, ydata)
    :( Float64.($(esc(fn)).(Double64.($(esc(xdata))), Double64.($(esc(ydata))) )) )
end

macro via_df64(fn, xdata, ydata, zdata)
    :( Float64.($(esc(fn)).(Double64.($(esc(xdata))), Double64.($(esc(ydata))), Double64.($(esc(zdata))) )) )
end

macro via_df32(fn, data)
    :( Float32.($(esc(fn)).(Double32.($(esc(data))) )) )
end

macro via_df32(fn, xdata, ydata)
    :( Float32.($(esc(fn)).(Double32.($(esc(xdata))), Double32.($(esc(ydata))) )) )
end

macro via_df32(fn, xdata, ydata, zdata)
    :( Float64.($(esc(fn)).(Double32.($(esc(xdata))), Double32.($(esc(ydata))), Double32.($(esc(zdata))) )) )
end
