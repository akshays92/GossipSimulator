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
  
    case topology do
      "LINE" -> line(numNodes, algorithm, nil, 1)
      "2DGRID" -> initialize(numNodes, algorithm, 1)
      "IMPERFECT2DGRID" -> imperfect2DGrid(numNodes, algorithm)
      "FULLNETWORK" -> fullNetwork(numNodes, algorithm)
    end

  end

  def initialize(numNodes, algorithm, nodeNo) do
    list = []
    col = 0
    row = 0
    twoDGrid(numNodes, algorithm, nodeNo, list, col, row)
  end
  #to be called when Line topology is requested
  def line(numNodes, algorithm, left, nodeNo) when nodeNo<=numNodes do
    {:ok, current}=Project2.LineServer.start_link(nodeNo)
    Project2.LineServer.setLeft(current,left)
    Project2.LineServer.setRight(left,current)
    Project2.LineServer.setCurrent(current)
    line(numNodes, algorithm,current,nodeNo+1)
  end

  def line(numNodes, algorithm, left, nodeNo) when nodeNo>numNodes do
    Project2.LineServer.receiveGossip(left, "Ashley is sleeping with Jon Doe")
    unlimitedLoop()   
  end

  #to be called when 2dGrid topology is requested
  
  def twoDGrid(numNodes, algorithm, nodeNo, list, col, row) when nodeNo<=numNodes do
   
    {:ok, current}=Project2.GridServer.start_link(nodeNo)
    list = list ++ [current]

    list2 = Project2.GridServer.setColRow(current, col, row, nodeNo,numNodes)
    IO.inspect list2
    twoDGrid(numNodes, algorithm, nodeNo+1, list, row, col)
  end 

  def twoDGrid(numNodes, algorithm, nodeNo, list, col, row) when nodeNo>numNodes do
    IO.inspect list

  end

  #to be called when Imperfect2DGrid topology is requested
  def imperfect2DGrid(numNodes, algorithm) do
    IO.puts ("Imperfect2DGrid hai")
    IO.puts (numNodes)
    IO.puts (algorithm)
  end

  #to be called when FullNetwork topology is requested
  def fullNetwork(numNodes, algorithm) do
  
    IO.puts ("FullNetwork hai")
    IO.puts (numNodes)
    IO.puts (algorithm)
  end

  #to keep the main thread running
  def unlimitedLoop do
    unlimitedLoop
  end


end
