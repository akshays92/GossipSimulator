defmodule Project2.LineServer do
    use GenServer

    #Genserver DEF functions    
    def start_link(s, algorithm) do
        #GenServer.start_link(__MODULE__,%{s: s, w: w, left: left, right: right}, name: :CoinServer
        GenServer.start_link(__MODULE__,%{s: s, w: 1, left: nil, current: nil, right: nil, count: 0, gossip_string: "", maxCount: 10, algorithm: algorithm})
    end

    def init(init_data) do
        {:ok,init_data} 
    end


    #client callable functions

    #set pid for left node (received as arguement left) of this actor (received pid)
    def setLeft(pid, left) do
        GenServer.cast(pid, {:setLeft, left})
    end

    #set pid for current node (received as arguement pid) of this actor (received pid). Makes the node self-sentinent LOL
    def setCurrent(pid) do
        GenServer.cast(pid, {:setCurrent, pid})
    end

    #set pid for right node (received as arguement right) of this actor (received pid)
    def setRight(pid, right) do
        GenServer.cast(pid, {:setRight, right})
    end

    #set gossip for the target pid
    def setGossip(pid, gossip) do
        GenServer.cast(pid, {:setGossip, gossip})
    end

    #receive gossip of this actor
    def getGossip(pid) do
        GenServer.call(pid, {:getGossip})
    end

    #printing this node
    def printNode(pid) do
        GenServer.cast(pid, {:printNode})
    end
    
    
    #callback functions / p2p server side functions
    #topology implementing functions
    def handle_cast({:setLeft, pid}, state) do
        state=Map.put(state,:left,pid)
        {:noreply, state}
    end
    def handle_cast({:setCurrent, pid}, state) do
        state=Map.put(state,:current,pid)
        {:noreply, state}
    end
    def handle_cast({:setRight, pid}, state) do
        state=Map.put(state,:right,pid)
        {:noreply, state}
    end
    
    def handle_cast({:printNode}, state) do
        IO.inspect state
        #IO.puts Integer.to_string(Map.get(state,:s)) <> ":  " 
        #IO.inspect Map.get(state,:current) 
        {:noreply, state}
    end

    
    #Gossip protocol implementing functions
    def handle_cast({:setGossip, gossip}, state) do
        state=Map.put(state,:count,Map.get(state,:count)+1)
        state=Map.put(state,:gossip_string,gossip)
        
        pid=Map.get(state,Enum.random([:left, :right]))
        if Map.get(state,:count) < Map.get(state,:maxCount) do
            if is_pid(pid) do
                GenServer.cast(pid, {:setGossip, Map.get(state,:gossip_string)})
            end
            setGossip(Map.get(state,:current),Map.get(state,:gossip_string))
        else
            printNode(Map.get(state,:current))
        end
        {:noreply, state}
    end

    def handle_call({:getGossip}, _from, state) do
        {:reply, Map.get(state, :gossip_string), state}
    end

    def handle_cast({:spreadGossip}, state) do
        list=[:left, :right]
        gossip=Map.get(state,:gossip_string)
        setGossip( Map.get(state,Enum.random(list)),gossip)
        {:noreply,state}
    end

end