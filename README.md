# CustomJSONDecoder

自己写的一个 JSON Decoder，Parser 部分直接使用了 [vdka 大神写的这个 Parser](https://github.com/vdka/JSON)，因为我对于 Parser 这东西没什么认识，想学习一下，所以是跟着手撸了一份，而不是通过包管理工具集成进来，如果是想看一下 Parser 的部分，我觉得也可以看一下我的那一份实现，我自己花了时间理解的地方都有写注释，而且写得会跟 Swifty 一点。

Decoder 部分的抽象比原生的更加简洁一点，错误处理没有原生的那么完整，我觉得总体而言比原生的会更容易理解一点，在 decoder unbox 的那一部分，我基本上都尽可能去做兼容，例如数字 0 跟 1 可以被解析为 Bool 类型，原生的会更加严格一点，我甚至一度以为这是原生 Decoder 的 bug（在看了源码之后），跟 Swift 开发组的人员沟通之后得到的答复是 [Looks correct to me. 1 isn’t a Boolean. NSNumber defines 1 and true to be isEqual: though](https://twitter.com/jckarter/status/930767130898849792)。

性能方面，大概是比原生的快了一倍，大家可以跑一遍测试看看，我没有很深入的探究具体原因，但我觉得主要是原生的 JSONDecoder 内部直接使用了 `JSONSerilization` 将数据格式化为 `[String: Any]`，字典里的数据基本上都是 OC 对象或者 CF 对象，在 decode 为 Model 的时候，会多次使用 `as` 进行动态类型转换，导致性能低下。

而我这一份实现之所以比原生的快出一倍，主要是因为使用了 `JSONObject`，取出内部数据时是直接模式匹配，不需要类型转换，所以会更快。这一点是我在看 vdka 大神的 parser 的时候发现的，大家可以 clone 一份跑个测试看看，vdka 大神的 parser 在测试里比原生的速度慢，但是在模型转换测试里，反而比原生的更快，后面我才发现 parse 产出的类型不同，才导致了这样的差异。

这个 Decoder 目前只能算是个玩具，我只写了一个简单的性能测试，没有完备的测试，之后应该会补上。

写完这个之后，我又看到了很多人在吐槽原生 Decoder 数据兼容性的问题，例如 0 跟 1 不能解析为 `Bool`，我觉得给 Decoder 加多一些 DecodingOption 并不能解决问题，而是可以给 Model 加一个 `willDecode` 方法：

```swift
// 这里的代码只是表达思路，请不要当真
protocol CodableModel: Codable {
    func willDecode(data: JSONObject) -> JSONObject
}

struct Model: CodableModel {

    let aBooleanProperty: Bool
    
    func willDecode(data: JSONObject) -> JSONObject {
        var data = data

        if data["aBooleanProperty" == 0 {
            data["aBooleanProperty"] = true
        } else if data["aBooleanProperty"] == 1 {
            data["aBooleanProperty"] = false
        }

        return data
    }
}
```

在解析之前，如果发现 Model 遵循 `CodableModel` 的话，就先用 `willDecode` 做一次数据处理，这样就可以有相对更高的灵活度了，但这种深度依赖 JSONDecoder 内部实现的方式其实也不太好，最根本的解决方式还是后端接口的标准化。
