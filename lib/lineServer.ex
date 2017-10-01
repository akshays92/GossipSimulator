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
        GenServer.cast(pid, {:gossipSend, gossip})
    end

    #printing this node
    def printNode(pid) do
        GenServer.cast(pid, {:printNode})
    end

    #receive gossip of this actor
    def getGossip(pid, gossip) do
        GenServer.call(pid, {:gossipReceive, gossip})
    end

    

    #callback functions / p2p server side functions
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
        {:noreply, state}
    end

    





end