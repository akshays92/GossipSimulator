defmodule Project2 do
  @moduledoc """
  This is the main module of the project.
  This module invoked by running ./project2

  Below is the defination of the main function which is invoked when the application is invoked for the first time.
  It takes input the commandline arguements and invokes the appropriate 
  genserver modules and the n number of actors running on that genserver
  @args numNodes topology algorithm
  numNodes: Nnmber of nodes the topology must contain
  topology: FullNetwork, 2DGrid, Line, Imperfect2DGrid
  algorithm : gossip, push-sum
  """
  def main(args) do
    
    numNodes=String.to_integer(Enum.at(args,0))
    #IO.puts is_integer(numNodes)
    
    topology=(Enum.at(args,1))
    #IO.puts is_binary(topology)

    algorithm=(Enum.at(args,2))
    #IO.puts is_binary(algorithm)

    IO.puts("Please run")
    
  
  end

end
