using CSV, DataFrames

function readData(BranchFile, BusFile, GenFile)
    # 1. Getting branch/lines' data
    BranchData = CSV.read(BranchFile, DataFrame)
        NBuses = max(maximum(BranchData[:,:fbus]),maximum(BranchData[:,:tbus]))
        Buses = 1:NBuses
        NLines = size(BranchData,1)

        # 1.1. Branch Impedance and Admittance Parameters
        BranchData[!,:Z] = BranchData[!,:R] + im*BranchData[!,:X];
        BranchData[!,:Y] = 1 ./ BranchData[!,:Z];

        # 1.2. Creating Admittance Matrix - Y_bus
        Y_bus = zeros(Complex,NBuses,NBuses);


        # 1.2.1. Non-diagonal elements
        for i = 1:NLines
            # Admittance Matrix
            Y_bus[BranchData[i,:fbus], BranchData[i,:tbus]] = -BranchData[i, :Y]
            Y_bus[BranchData[i,:tbus], BranchData[i,:fbus]] = -BranchData[i, :Y]
        end

        # 1.2.2. Diagonal elements
        for i = 1:NBuses
            for j =1:NLines
                if (i==BranchData[j,:fbus])||(i==BranchData[j,:tbus])
                    # Admittance Matrix
                    Y_bus[i,i] += BranchData[j, :Y] + 0.5*im*BranchData[j,:b]

                end
            end
        end

        # 1.3. Splitting Ybus into ral and imag parts
        G = real.(Y_bus)
        B = imag.(Y_bus)

        # 1.4. Shunt susceptance
        b = zeros(6,6)
            for l in 1:NLines
                b[BranchData[l,:fbus],BranchData[l,:tbus]] = BranchData[l,:b]
                b[BranchData[l,:tbus],BranchData[l,:fbus]] = BranchData[l,:b]
            end


        # 1.5. Getting line capacities
            S = zeros(6,6)
                for l in 1:NLines
                    S[BranchData[l,:fbus],BranchData[l,:tbus]] = BranchData[l,:rate]
                    S[BranchData[l,:tbus],BranchData[l,:fbus]] = BranchData[l,:rate]
                end

    # 2. Getting nodal data
    BusData = CSV.read(BusFile, DataFrame)

    # 3. Getting generation data
    GenData = CSV.read(GenFile, DataFrame)


    return G, B, b, S, BusData, GenData
end
