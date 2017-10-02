defmodule Project2.LineServer do
    use GenServer

    #Genserver DEF functions    
    def start_link(s) do
        #GenServer.start_link(__MODULE__,%{s: s, w: w, left: left, right: right}, name: :CoinServer
        GenServer.start_link(__MODULE__,%{s: s, w: 1, left: nil, current: nil, right: nil, count: 0, gossip_string: "", maxCount: 100, convergence: false})
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

    #spreading gossip for the target pid
    def sendGossip(pid, gossip) do
        GenServer.cast(pid, {:sendGossip, gossip})
    end

    def receiveGossip(pid, gossip) do
        GenServer.cast(pid, {:receiveGossip, gossip})
    end

    #printing this node
    def printNode(pid) do
        GenServer.cast(pid, {:printNode})
    end

    #Check if node is converged
    def isConverged(pid) do
        GenServer.call(pid, {:isConverged})
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

    #Gossip receiving function
    def handle_cast({:receiveGossip, gossip}, state) do
        if(Map.get(state,:count)<1) do
            sendGossip(Map.get(state,:current),gossip)
            IO.puts ("Bitch "<>Integer.to_string(Map.get(state,:s)) <> " is spreading gossip that "<>gossip)
        end
        state=Map.put(state,:count,Map.get(state,:count)+1)
        state=Map.put(state,:gossip_string,gossip)            
        {:noreply, state}
    end
    
    #Gossip sending function
    def handle_cast({:sendGossip, gossip}, state) do
        #IO.puts ("Bitch "<>Integer.to_string(Map.get(state,:s)) <> " is spreading gossip that "<>gossip)
        if(Map.get(state,:count)<Map.get(state,:maxCount)) do
            sendGossip(Map.get(state,:current),gossip)
            list=[:left,:right, :current]
            pid=Map.get(state,Enum.random(list))
            if is_pid(pid) do
                GenServer.cast(pid,{:receiveGossip,gossip})
            end
        else
            IO.puts ("Bitch "<>Integer.to_string(Map.get(state,:s)) <> " is spreading bored of the old news")
        end
        {:noreply, state}
    end
    #Check Node for convergence
    def handle_call(:isConverged, _from, state) do
        {:reply,Map.get(state,:converged)}
    end

end