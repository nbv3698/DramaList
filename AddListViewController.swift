//
//  AddListTableViewController.swift
//  List
//
//  Created by Len on 2017/6/11.
//  Copyright © 2017年 Len. All rights reserved.
//

import UIKit
import AVFoundation

class AddListViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{
    
    var datePicker : UIDatePicker!
    var selectImage: UIImage!
    var myPlayer :AVAudioPlayer!
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    //@IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = nil
        nameTextField.placeholder = "請輸入劇名"
        dateTextField.text = nil
        dateTextField.placeholder = "請選擇播放日期"

        
        //初始化UIDatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.datePickerMode = UIDatePickerMode.date
        dateTextField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        dateTextField.inputAccessoryView = toolBar
        
        // 建立播放器
        let soundPath = Bundle.main.path(
            forResource: "yes_1", ofType: "wav")
        do {
            myPlayer = try AVAudioPlayer(
                contentsOf: NSURL.fileURL(withPath: soundPath!))
            
            // 重複播放次數 設為 0 則是只播放一次 不重複
            myPlayer.numberOfLoops = 0
            
        } catch {
            print("error")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        
        let alert = UIAlertView()
        //檢查輸入
        if (nameTextField.text?.isEmpty)! {
            alert.title = "提示"
            alert.message = "請輸入名稱"
            alert.addButton(withTitle: "Ok")
            alert.show()

        }
        else if selectImage == nil{
            alert.title = "提示"
            alert.message = "請選擇相片"
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
        else{
            myPlayer.play()
            
            let fileName = Date().timeIntervalSinceReferenceDate
            print("fileName:")
            print(fileName)
            
            let dic:[String:String] = ["name":nameTextField.text!,
                                       "comment":commentTextView.text!,
                                       "date":dateTextField.text!,
                                       "fileName":"\(fileName)"]
            
            
            if let dataToSave = UIImagePNGRepresentation(selectImage){
                // 產生路徑
                let filePath = NSTemporaryDirectory() + "\(fileName)" + ".png"
                let fileURL = URL(fileURLWithPath: filePath)
                // 寫入
                do{
                    try dataToSave.write(to: fileURL)
                }
                catch{
                    print("Can not save Image")
                }
                print("圖片路徑：")
                print(filePath)
            }
        
            let notiName = Notification.Name("addNotification")
            NotificationCenter.default.post(name: notiName, object: nil, userInfo: dic)
        
            navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func chooseDateAction(_ sender: UITextField) {
        
        self.pickUpDate(sender)
    }
    
    func pickUpDate(_ textField : UITextField){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if textField.tag==1
        {
            if let text = dateTextField.text, !text.isEmpty
            {
                datePicker.date=dateFormatter.date(from:dateTextField.text!)!
                
            }
            
        }
    }
    
    func doneClick(_ textField : UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyyy/MM/dd"
        if dateTextField.isFirstResponder{
            dateTextField.text = dateFormatter.string(from: datePicker.date)
            dateTextField.resignFirstResponder()
        }
    }
    
    func cancelClick() {
        if dateTextField.isFirstResponder{
            dateTextField.resignFirstResponder()
        }
    }

    
    //选取相册
    @IBAction func fromAlbum(_ sender: AnyObject) {
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //设置是否允许编辑
            picker.allowsEditing = true
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
    }
    
    //选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        //查看info对象
        //print(info)
        
        //显示的图片
        let image:UIImage!
        
        //获取编辑后的图片
        image = info[UIImagePickerControllerEditedImage] as! UIImage
        //socialMedia?.image = info[UIImagePickerControllerEditedImage] as! UIImage
        selectImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        imageView?.image = image
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }

    // MARK: - Table view data source
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
