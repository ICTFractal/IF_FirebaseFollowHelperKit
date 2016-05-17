# IF_FirebaseFollowHelperKit
Firebaseにユーザフォロー機能を追加します。  
ドキュメントは[こちら](http://ict-fractal.com/OSSDoc/IF_FirebaseFollowHelperKit/index.html)です。

## Features
1. Firebaseのデータ構造を意識せずに、フォロー関連の機能を利用できます。
2. 他ユーザがログインユーザに関わる操作を行った場合、リアルタイムに通知を受け取る事ができます。
3. 単純なArrayで処理結果が返されるので、filterなどの加工処理が容易です。

## How to use
### 前提条件
IF_FirebaseFollowHelperKitはFirebaseに機能を追加するため、Firebaseが動作している事が前提条件となります。  
またユーザ識別に認証情報を利用するため、認証済みのFirebaseインスタンスを利用する必要があります。

### 初期化
self.firebaseRefは認証済みのFirebaseインスタンスです。
```
let followHelper = IF_FirebaseFollowHelper(firebaseRef: self.firebaseRef)
```

### ユーザをフォローする
```
let uid = 対象ユーザのuid
followHelper.follow(uid)
```

### ユーザのフォローを解除する
```
let uid = 対象ユーザのuid
followHelper.unFollow(uid)
```

### 認証ユーザがフォローしているユーザのリストを得る
```
followHelper.getFollowList() { followList in
  print(followList)
}
```

### 認証ユーザをフォローしているユーザのリストを得る
```
followHelper.getFollowerList() { followerList in
  print(followerList)
}
```

### ユーザをブロックする
```
let uid = 対象ユーザのuid
followHelper.block(uid)
```

### ユーザのブロックを解除する
```
let uid = 対象ユーザのuid
followHelper.unBlock(uid)
```

### 認証ユーザがブロックしているユーザのリストを得る
```
followHelper.getBlockList() { blockList in
  print(blockList)
}
```

### 認証ユーザをブロックしているユーザのリストを得る
```
followHelper.getBlockerList() { blockerList in
  print(blockerList)
}
```

### イベントを受信する
例えばどこか別の場所であるユーザが認証ユーザをフォローした時など、リアルタイムにヘルパーからメッセージが発行されます。  
メッセージは *NSNotificationCenter.defaultCenter()* を介して通知されるので、受信したい場所にオブザーバを登録してください。  
発行されるメッセージは[こちら](http://ict-fractal.com/OSSDoc/IF_FirebaseFollowHelperKit/Structs/IF_FirebaseFollowHelperMessage.html)をご覧下さい。  

例）他のユーザが認証ユーザをフォローした際に通知される **AddedFollower** メッセージを受け取ります  
```
override func viewDidLoad() {
  super.viewDidLoad()
	NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleNotification(_:)), name: nil, object: nil)
}

func handleNotification(notification: NSNotification) {
  if notification.name == IF_FirebaseFollowHelperMessage.AddedFollower {
    if let uid = userInfo["uid"] as? String, let timestamp = userInfo["timestamp"] as? NSDate {
      print("[\(uid)] followed you. \(timestamp)")
    }
  }
}
```

## Runtime Requirements
Firebase

## Installation and Setup
プロジェクトに *IF_FirebaseFollowHelper.swift* を追加してください。

## Demo Setup
デモを確認する場合、次の手順を実施してください。  
1. Demoディレクトリで *pod install* を実行し、Firebaseを環境に追加します。  
2. 作成された *Demo.xcworkspace* を開きます。  
3. *UsersViewController.swift* 内にある *firebaseURL* に、Firebase Data URLを設定します。  

## License
[MIT License](https://github.com/ICTFractal/IF_FirebaseFollowHelperKit/edit/master/LICENSE)

## Author
[ICT Fractal](https://github.com/ICTFractal)
