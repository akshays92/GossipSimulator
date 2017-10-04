defmodule Project2.LineServer do
    use GenServer

    #Genserver DEF functions    
    def start_link(s) do
        #GenServer.start_link(__MODULE__,%{s: s, w: w, left: left, right: right}, name: :CoinServer
        GenServer.start_link(__MODULE__,%{s: s, w: 1.0, left: nil, current: nil, right: nil, count: 0, gossip_string: "", maxCount: 100, pushSumConvergenceCount: 0})
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

    #GOSSIP PROTOCIOL CLIENT FUNCTIONS
    #spreading gossip for the target pid
    def sendGossip(pid, gossip) do
        GenServer.cast(pid, {:sendGossip, gossip})
    end
    #receive the gossip for the target PID
    def receiveGossip(pid, gossip) do
        GenServer.cast(pid, {:receiveGossip, gossip})
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

    #GOSSIP PROTOCIOL SERVER FUNCTIONS
    #Gossip receiving function
    def handle_cast({:receiveGossip, gossip}, state) do
        if(Map.get(state,:count)<1) do
            sendGossip(Map.get(state,:current),gossip)
            #IO.puts ("Bitch "<>Integer.to_string(Map.get(state,:s)) <> " is spreading gossip that "<>gossip)
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
                receiveGossip(pid,gossip)
            end
        else
            IO.puts ("Node\t"<>Integer.to_string(Map.get(state,:s)) <> "\thas converged")
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
            #IO.puts List.to_string(:erlang.pid_to_list(Map.get(state,:current))) <> " has set cause naya is purana"
            #IO.puts Float.to_string(naya_ratio) <>"  "<> Float.to_string(purana_ratio)  
        else
            state=Map.put(state,:pushSumConvergenceCount,0)
            #IO.puts List.to_string(:erlang.pid_to_list(Map.get(state,:current))) <> " has reset cause naya is not purana"
            #IO.puts Float.to_string(naya_ratio) <>"  "<> Float.to_string(purana_ratio)  
        end

        if(Map.get(state,:count)<1) do
            sendPushSum(Map.get(state,:current))
            IO.puts (List.to_string(:erlang.pid_to_list(Map.get(state,:current))) <> "\thas started push sum")
            state=Map.put(state,:count,Map.get(state,:count)+1)            
        end
        {:noreply, state}
    end
    #PUSH-SUM sending function
    def handle_cast({:sendPushSum}, state) do
        :timer.sleep(10)
        if(Map.get(state,:pushSumConvergenceCount) < 20) do
            list=[:left,:right, :current]
            pid=Map.get(state,Enum.random(list))
            if is_pid(pid) do
                apne_ka_half_s=Map.get(state,:s)/2;
                apne_ka_half_w=Map.get(state,:w)/2;
                state=Map.put(state,:s,apne_ka_half_s)
                state=Map.put(state,:w,apne_ka_half_w)
                receivePushSum(pid,apne_ka_half_s, apne_ka_half_w)
            end
            sendPushSum(Map.get(state,:current))
        else
            IO.puts (List.to_string(:erlang.pid_to_list(Map.get(state,:current)))<> "\has converged")
            IO.puts Float.round(Map.get(state,:s)/Map.get(state,:w),10)

        end
        {:noreply, state}
    end


    
    #Check Node for convergence
    def handle_call(:isConverged, _from, state) do
        {:reply,Map.get(state,:converged)}
    end

end