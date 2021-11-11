function readBranch(BranchFile)

    BranchData = CSV.read(BranchFile, DataFrame)
        NBuses = max(maximum(BranchData[:,:FromBus]),maximum(BranchData[:,:ToBus]))
        Buses = 1:NBuses
        NLines = size(BranchData,1)

        # Branch Impedance and Admittance Parameters
        BranchData.Z = BranchData.R + im*BranchData.X;
        BranchData.Y = 1 ./ BranchData.Z;

        # Creating Admittance Matrix - Y_bus
        Y_bus = zeros(Complex,NBuses,NBuses);


        # Non-diagonal elements
        for i = 1:NLines
            # Admittance Matrix
            Y_bus[BranchData[i,:FromBus], BranchData[i,:ToBus]] = -BranchData[i, :Y]
            Y_bus[BranchData[i,:ToBus], BranchData[i,:FromBus]] = -BranchData[i, :Y]
        end

        # Diagonal elements
        for i = 1:NBuses
            for j =1:NLines
                if (i==BranchData[j,:FromBus])||(i==BranchData[j,:ToBus])
                    # Admittance Matrix
                    Y_bus[i,i] += BranchData[j, :Y]

                end
            end
        end
        GL = real.(Y_bus)
        BL = imag.(Y_bus)

        return Buses, GL, BL
end
