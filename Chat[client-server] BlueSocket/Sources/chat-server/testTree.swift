
class Test{
    var testTree = BinaryTreeMap<String, String>()



    func toTree(){
        do{
            try testTree.put(key: "nbc.com", value: "66.77.124.26")
            print("\(testTree.root!) \n")

            try testTree.put(key: "facebook.com", value: "69.63.181.12")
            try testTree.put(key: "yelp.com", value: "63.251.52.110")
            try testTree.put(key: "google.com", value: "69.63.189.16")
            try testTree.put(key: "viacom.com", value: "206.220.43.92")
            try testTree.put(key: "zappos.com", value: "66.209.92.150")
            try testTree.put(key: "ucla.edu", value: "169.232.55.22")
            try testTree.put(key: "xing.com", value: "213.238.60.19")
            try testTree.put(key: "wings.com", value: "12.155.29.35")
            try testTree.put(key: "boingboing.net", value: "204.11.50.136")


        }catch SymbolTableError.maxCapacityReached{
            print("Max Capacity reached")
            let _ = testTree.remove(key: "yelp.com")

        }catch{

        }
        print("TRAVERSE")
        testTree.traverse{key, value in
            print("\(key) => \(value)")

        }
    }

    func remove(){
        let borrado = testTree.remove(key: "facebook.com") ?? "nil"
        print("\(borrado)")
    }

    func depth(){
        let prof = testTree.depth()
        print("\(prof)")
    }

    func getValue(){
        let value = testTree.get(key: "viacom.com") ?? nil 
        print("Value for viacom.com -> \(value!)")

    }



}






