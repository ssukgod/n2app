//
//  EXEventStoreRepository.swift
//  n1app
//
//  Created by sky on 2020/10/24.
//  Copyright © 2020 sky. All rights reserved.
//

import Foundation
import EventKit

class EXEventStoreRepository {
    static let shared = EXEventStoreRepository()
    
    let ekEventStore = EKEventStore()
    
    
    //カレンダーに接続権限があるか確認
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        
        //.authorized 許可されてる
        //.denied 拒否されてる
        //.notDetermined まだ許可設定してない. アクセス許可のメッセージを開いていない
        //.restricted
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    //notDeterminedの時に、接続権限を要求するポップアップを出す
    //@escaping 呼び出したときに、変数を解放しない
    func requestCalenderAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        ekEventStore.requestAccess(to: .event, completion: completion)
    }
    
    //OSのデフォルトのカレンダーに接続
    func accessDefaultCalender() -> EKCalendar {

        return ekEventStore.defaultCalendarForNewEvents!
    }
    
    
    // キャプチャリスト ... クロージャーの外の変数のスコープをどのように扱うか指定する。
    // selfは自分自身のクラスインスタンスのため、自分自身のクラスが存在しなくなった時に、
    // 処理を終わらせたい時は、キャプチャリストを指定しないといけない。
    // 指定しない場合の規定値はstrong(強参照)で処理が終了しない限り絶対に開放しないので、
    // VCが開放されても、クロージャーが存在するため、VCも解放されないメモリリークが発生する。
    // (最新のXcodeだと自動で開放されるみたいだけど、基本意識して開放したほうがいい)
    // なので外部(クロージャーの外)の変数をつけるときはweakのキャプチャリスト
    // 同じメンバ変数のtableViewなどは指定する。
    // weakにすると、weakに指定した変数はnil許容型にになるので、
    // guard letでunwrapすると良い。
    // unownedにするとnil許容しない型になるけど、
    // selfがnilになるタイミングで呼ばれると異常終了する。
    // 呼び出したタイミングで実行時エラー
//    eventStore.requestEventAccess {
//        [weak self/*,unowned self, weak tableView*/] (accsess: Bool, error: Error?) -> ()/*Void*/ in
//
//        // selfをnil許容しない型に変換する
//        guard let self = `self` else {
//            return
//        }

    
    
    
    
    
    
    
    
    
    
    
    
    
}
