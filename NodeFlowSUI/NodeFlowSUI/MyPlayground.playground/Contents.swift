import Cocoa
import Combine

var cancellable: AnyCancellable?

let graph = Graph()

let node1 = MathNode()
let node2 = MathNode()

graph.addNode(node1)
graph.addNode(node2)

let output = NumberProperty(value: 1, isInput: false)
let input  = NumberProperty(value: 0, isInput: true)

let connection = Connection(output: output, input: input)

graph.addConnection(connection)

//dump(graph)

//cancellable = output.$value.assign(to: \.value, on: input)

output.value = 2

connection.output.value
connection.input.value
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
    print(connection.input.value)
}
connection.cancellable
graph
