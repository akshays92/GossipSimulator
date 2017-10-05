defmodule Project2.Imperfect2DGrid do
    use GenServer
    #Genserver DEF functions    
    def start_link(s, maxCount,x,y) do
        GenServer.start_link(__MODULE__,%{s: s, w: 1.0, left: nil, current: nil, right: nil, up: nil, down: nil, random: nil, count: 0, gossip_string: "", maxCount: maxCount, pushSumConvergenceCount: 0,x: x, y: y})
    end

    def init(init_data) do
        {:ok,init_data} 
    end

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

    #set pid for right node (received as arguement right) of this actor (received pid)
    def setUp(pid, up) do
        GenServer.cast(pid, {:setRight, up})
    end

    #set pid for right node (received as arguement right) of this actor (received pid)
    def setRandom(pid, random) do
        GenServer.cast(pid, {:setRight, random})
    end

    #set pid for right node (received as arguement right) of this actor (received pid)
    def setDown(pid, down) do
        GenServer.cast(pid, {:setRight, down})
    end

    #for debugging and printing the current node
    def printNode(pid) do
        GenServer.cast(pid, {:printNode})
    end

    #Client side topology implementing functions
    def handle_cast({:printNode}, state) do
        #IO.inspect state
        IO.puts " x:" <>Integer.to_string(Map.get(state,:x)) <> " y:" <>Integer.to_string(Map.get(state,:y))<>" :"<>List.to_string(:erlang.pid_to_list(Map.get(state,:current))) 
        {:noreply, state}
    end
    def handle_cast({:setCurrent, pid}, state) do
        state=Map.put(state,:current,pid)
        {:noreply, state}
    end





end
