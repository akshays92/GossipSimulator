defmodule Project2 do
  @moduledoc """
  This is the main module of the project.
  This module invoked by running ./project2

  Below is the defination of the main function which is invoked when the application is invoked for the first time.
  It takes input the commandline arguements and invokes the appropriate 
  genserver modules and the n number of actors running on that genserver
  @args numNodes topology algorithm
  numNodes: Nnmber of nodes the topology must contain
  topology: Line, 2DGrid,  Imperfect2DGrid, FullNetwork
  algorithm : gossip, push-sum
  """
  def main(args) do
    
  #getting the commandline arguements
    numNodes=String.to_integer(Enum.at(args,0))
    topology=(String.upcase(Enum.at(args,1)))
    algorithm=(String.upcase(Enum.at(args,2)))
    nodeList=[]
    firstNodeNo=1
    maxCount=10
    case topology do
      "LINE" -> line(numNodes, algorithm, nil,firstNodeNo, nodeList, maxCount)
      "2DGRID" -> imperfect2DGrid(topology,:math.ceil(:math.sqrt(numNodes))*:math.ceil(:math.sqrt(numNodes)), algorithm,1,maxCount,0,0,%{},nodeList)
      "IMPERFECT2DGRID" -> imperfect2DGrid(topology,:math.ceil(:math.sqrt(numNodes))*:math.ceil(:math.sqrt(numNodes)), algorithm,1,maxCount,0,0,%{},nodeList)
      "FULLNETWORK" -> fullNetwork(numNodes, algorithm,nodeList,firstNodeNo,maxCount)
    end

  end

  #LINE ###############################################################################
  #to be called when Line topology is requested
  def line(numNodes, algorithm, left, nodeNo, list,maxCount) when nodeNo<=numNodes do
    {:ok, current}=Project2.LineServer.start_link(nodeNo,maxCount)
    #list=[current]++list
    Project2.LineServer.setLeft(current,left)
    Project2.LineServer.setRight(left,current)
    Project2.LineServer.setCurrent(current)
    line(numNodes, algorithm,current,nodeNo+1, [current|list],maxCount)
  end

  def line(numNodes, algorithm, left, nodeNo, list,maxCount) when nodeNo>numNodes do
    if String.equivalent?(algorithm,"GOSSIP") do
      Project2.LineServer.sendGossip(Enum.random(list), "Abra ka dabra")
      unlimitedLoop() 
    else
      if String.equivalent?(algorithm,"PUSH-SUM") do
        Project2.LineServer.sendPushSum(Enum.random(list))  
        unlimitedLoop() 
      else
        IO.puts("INCORRECT ALGORITHM")
      end
    end
    #IO.inspect list  
  end
  #FULL NETWORK #######################################################################################
  #to be called when FullNetwork topology is requested
  def fullNetwork(numNodes, algorithm,list,nodeNo,maxCount) when nodeNo<=numNodes do
    {:ok, current}=Project2.FullNetworkServer.start_link(nodeNo,maxCount)
    Project2.FullNetworkServer.setCurrent(current)
    fullNetwork(numNodes, algorithm,[current|list],nodeNo+1,maxCount)
  end
  def fullNetwork(numNodes, algorithm,list,nodeNo,maxCount) when nodeNo>numNodes do
    for pid <- list do
      Project2.FullNetworkServer.setMyAddressBook(pid,list)
    end
    if String.equivalent?(algorithm,"GOSSIP") do
      Project2.FullNetworkServer.sendGossip(Enum.random(list), "Abra ka dabra")
      unlimitedLoop() 
    else
      if String.equivalent?(algorithm,"PUSH-SUM") do
        Project2.FullNetworkServer.sendPushSum(Enum.random(list))  
        unlimitedLoop() 
      else
        IO.puts("INCORRECT ALGORITHM")
      end
    end
  end

  #IMPERFECT 2D GRID ###################################################################################
  #to be called when Imperfect2DGrid topology is requested
  def imperfect2DGrid(topology,numNodes, algorithm,nodeNo,maxCount,x,y,map,nodeList) when nodeNo<=numNodes do
    {:ok, current}=Project2.Imperfect2DGrid.start_link(nodeNo,maxCount,x,y)
    if rem(nodeNo,trunc(:math.sqrt(numNodes)))==0 do
      new_x=0
      new_y=y+1
    else
      new_x=x+1
      new_y=y
    end
    map=Map.put(map,{x,y},current)
    Project2.Imperfect2DGrid.setCurrent(current)
    imperfect2DGrid(topology,numNodes, algorithm,nodeNo+1,maxCount,new_x,new_y,map,[current|nodeList])
  end
  def imperfect2DGrid(topology,numNodes, algorithm,nodeNo,maxCount,x,y,map,nodeList) when nodeNo>numNodes do
    for pid <- nodeList do
      #Project2.Imperfect2DGrid.printNode(pid)
      xyMap=Project2.Imperfect2DGrid.getXY(pid)
      new_x=Map.get(xyMap,:x)
      new_y=Map.get(xyMap,:y)
      addressBook=[]
      addressBook=[Map.get(map,{new_x,new_y-1})|addressBook]
      addressBook=[Map.get(map,{new_x,new_y+1})|addressBook]
      addressBook=[Map.get(map,{new_x+1,new_y})|addressBook]
      addressBook=[Map.get(map,{new_x-1,new_y})|addressBook]
      if String.equivalent?(topology,"IMPERFECT2DGRID") do
        addressBook=[Enum.random(nodeList)|addressBook]
      end
      Project2.Imperfect2DGrid.setMyAddressBook(pid,addressBook)
      #Project2.Imperfect2DGrid.printNode(pid)
    end
    if String.equivalent?(algorithm,"GOSSIP") do
      Project2.Imperfect2DGrid.sendGossip(Enum.random(nodeList), "Abra ka dabra")
      unlimitedLoop() 
    else
      if String.equivalent?(algorithm,"PUSH-SUM") do
        Project2.Imperfect2DGrid.sendPushSum(Enum.random(nodeList))  
        unlimitedLoop() 
      else
        IO.puts("INCORRECT ALGORITHM")
      end
    end
  end

  ######################################################################################################
  #to keep the main thread running
  def unlimitedLoop() do
    unlimitedLoop()
  end


end
