defmodule Project2.Imperfect2DGrid do
    use GenServer
    #Genserver DEF functions    
    def start_link(s, maxCount,x,y,start_time) do
        GenServer.start_link(__MODULE__,%{s: s, w: 1.0, current: nil,count: 0, gossip_string: "", addressList: [], maxCount: maxCount, pushSumConvergenceCount: 0,x: x, y: y, start_time: start_time})
    end

    def init(init_data) do
        {:ok,init_data} 
    end

    #topology implementing functions
    #set pid for current node (received as arguement pid) of this actor (received pid). Makes the node self-sentinent LOL
    def setCurrent(pid) do
        GenServer.cast(pid, {:setCurrent, pid})
    end
    #set the address list of current node
    def setMyAddressBook(pid,addressBook) do
        GenServer.cast(pid, {:setMyAddressBook, addressBook})
    end

    def getXY(pid) do
        GenServer.call(pid,{:getXY})
    end

    #for debugging and printing the current node
    def printNode(pid) do
        GenServer.cast(pid, {:printNode})
    end

    #GOSSIP PROTOCIOL CLIENT FUNCTIONS
    #spreading gossip for the target pid
    def sendGossip(pid, gossip) do
        GenServer.cast(pid, {:sendGossip, gossip})
    end
    #receive the gossip for the target PID
    def receiveGossip(pid, gossip) do
        GenServer.cast(pid, {:receiveGossip, gossip})
    end

    #setting start time
    def setStartTime(pid, starttime) do
        GenServer.cast(pid, {:setStartTime, starttime})
    end

    #PUSH-SUM PROTOCOL
    #spreading PUSH-SUM for the target pid
    def sendPushSum(pid) do
        GenServer.cast(pid, {:sendPushSum})
    end
    #receive the PUSH-SUM for the target PID
    def receivePushSum(pid, s,w) do
        GenServer.cast(pid, {:receivePushSum, s,w})
    end


    #Client side topology implementing functions
    def handle_cast({:printNode}, state) do
        IO.inspect state
        {:noreply, state}
    end
    def handle_cast({:setCurrent, pid}, state) do
        state=Map.put(state,:current,pid)
        {:noreply, state}
    end
    def handle_cast({:setMyAddressBook, addressBook}, state) do
        state=Map.put(state,:addressList,addressBook)
        {:noreply, state}
    end
    def handle_call({:getXY},_form,state) do
        {:reply,%{x: Map.get(state,:x),y: Map.get(state,:y)},state}
    end
    def handle_cast({:setStartTime, starttime}, state) do
        state=Map.put(state,:start_time,starttime)
        {:noreply, state}
    end

    #GOSSIP PROTOCIOL SERVER FUNCTIONS
    #Gossip receiving function
    def handle_cast({:receiveGossip, gossip}, state) do
        if(Map.get(state,:count)<1) do
            sendGossip(Map.get(state,:current),gossip)
            IO.puts ("Node: "<>List.to_string(:erlang.pid_to_list Map.get(state,:current)) <> "\t has started spreading the gossip")
        end
        state=Map.put(state,:count,Map.get(state,:count)+1)
        state=Map.put(state,:gossip_string,gossip)            
        {:noreply, state}
    end
    #Gossip sending function
    def handle_cast({:sendGossip, gossip}, state) do
        :timer.sleep(1)
        if(Map.get(state,:count)<Map.get(state,:maxCount)) do
            sendGossip(Map.get(state,:current),gossip)
            pid=Enum.random(Map.get(state,:addressList))
            if is_pid(pid) do
                receiveGossip(pid,gossip)
            end
        else
            duration = String.to_integer(to_string(:os.system_time(:millisecond))) - String.to_integer(Map.get(state, :start_time))            
            IO.puts ("Node: "<>List.to_string(:erlang.pid_to_list Map.get(state,:current)) <> "\thas converged with the gossip : "<>gossip <> " after " <> Integer.to_string(duration) <> " ms")
        end
        {:noreply, state}
    end

    #PUSH-SUM PROTOCIOL SERVER FUNCTIONS
    #PUSH-SUM receiving function
    def handle_cast({:receivePushSum, paraya_s, paraya_w}, state) do
        purana_ratio=Float.round((Map.get(state,:s)/Map.get(state,:w)),10)
        state=Map.put(state,:s,Map.get(state,:s)+paraya_s)
        state=Map.put(state,:w,Map.get(state,:w)+paraya_w)
        naya_ratio=Float.round((Map.get(state,:s)/Map.get(state,:w)),10)

        if (naya_ratio==purana_ratio) do
            state=Map.put(state,:pushSumConvergenceCount,Map.get(state,:pushSumConvergenceCount)+1)
        else
            state=Map.put(state,:pushSumConvergenceCount,0)
        end

        if(Map.get(state,:count)<1) do
            sendPushSum(Map.get(state,:current))
            IO.puts "Node: "<>(List.to_string(:erlang.pid_to_list(Map.get(state,:current))) <> "\thas started push sum")
            state=Map.put(state,:count,Map.get(state,:count)+1)            
        end
        {:noreply, state}
    end
    #PUSH-SUM sending function
    def handle_cast({:sendPushSum}, state) do
        :timer.sleep(1)
        if(Map.get(state,:pushSumConvergenceCount) < Map.get(state,:maxCount)) do
            pid=Enum.random(Map.get(state,:addressList))
            if is_pid(pid) do
                if !(pid==Map.get(state,:current)) do
                    apne_ka_half_s=Map.get(state,:s)/2;
                    apne_ka_half_w=Map.get(state,:w)/2;
                    state=Map.put(state,:s,apne_ka_half_s)
                    state=Map.put(state,:w,apne_ka_half_w)
                    receivePushSum(pid,apne_ka_half_s, apne_ka_half_w)
                end
            end
            sendPushSum(Map.get(state,:current))
        else
            duration = String.to_integer(to_string(:os.system_time(:millisecond))) - String.to_integer(Map.get(state, :start_time))            
            IO.puts "Node: "<>(List.to_string(:erlang.pid_to_list(Map.get(state,:current))))<> "\t has converged to " <> Float.to_string(Float.round(Map.get(state,:s)/Map.get(state,:w),10)) <> " after " <> Integer.to_string(duration) <> " ms"

        end
        {:noreply, state}
    end




end
