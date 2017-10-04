defmodule Project2.GridServer do
    use GenServer

    #Genserver DEF functions    
    def start_link(s) do
        #GenServer.start_link(__MODULE__,%{s: s, w: w, left: left, right: right}, name: :CoinServer
        GenServer.start_link(__MODULE__,%{s: s, w: 1, left: nil, current: nil, right: nil, count: 0, gossip_string: "", maxCount: 100, convergence: false})
    end

    def init(init_data) do
        {:ok,init_data} 
    end

    def setColRow(pid, col, row, nodeNo, numNodes) do
        GenServer.call(pid, {:setColRow, col, row, nodeNo, numNodes})
    end

    def handle_call({:setColRow, col,row, nodeNo, numNodes}, _from, state) do

       n = trunc(:math.ceil(:math.sqrt(numNodes)))
       if(rem(nodeNo, n) == 0) do
           row = trunc(:math.floor(nodeNo/n)) - 1
           col = rem(nodeNo, n) + (n-1)
       else
           col = rem(nodeNo, n) - 1
           row = trunc(:math.floor(nodeNo/n))
       end
       #IO.puts(row <> " " <> col)
       {:reply, {row,col}, state}

    end 
end