//
//  ListDetailViewController.swift
//  List
//
//  Created by Len on 2017/6/11.
//  Copyright © 2017年 Len. All rights reserved.
//

import UIKit

class ListDetailViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{

    var listDic:[String:String]!
    var selectImage: UIImage!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    var datePicker : UIDatePicker!
    
    
    @IBAction func chooseDateAction(_ sender: UITextField) {
        self.pickUpDate(sender)
    }
    
    func pickUpDate(_ textField : UITextField){
        // DatePicker
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = listDic["name"]
        nameTextField.text = listDic["name"]
        commentTextView.text = listDic["comment"]
        dateTextField.text = listDic["date"]
        
        //讀相片
        let filePath = NSTemporaryDirectory() + listDic["fileName"]! + ".png"
        let image = UIImage(contentsOfFile: filePath)
        selectImage = image
        //顯示相片
        imageView.image = image
        
        //UIDatePicker
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem){
        //檢查輸入
        if (nameTextField.text?.isEmpty)! {
            let alert = UIAlertView()
            alert.title = "提示"
            alert.message = "請輸入名稱"
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
        else{
            saveDate()
            //存相片
            if let dataToSave = UIImagePNGRepresentation(selectImage){
                // 產生路徑
                let filePath = NSTemporaryDirectory() + listDic["fileName"]! + ".png"
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
        
            let notificationName = Notification.Name("saveNotification")
            NotificationCenter.default.post(
                name: notificationName, object: nil, userInfo: listDic)
        
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    func saveDate()
    {
        if (listDic["fileName"]!.isEmpty){
            let fileName = Date().timeIntervalSinceReferenceDate
            
            listDic = ["name":nameTextField.text!,
                       "comment":commentTextView.text!,
                       "date":dateTextField.text!,
                       "fileName":"\(fileName)"
                        ]
            print("檔名為空")
        }

        else{
            listDic = ["name":nameTextField.text!,
                       "comment":commentTextView.text!,
                       "date":dateTextField.text!,
                       "fileName":listDic["fileName"]!
                        ]
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
        selectImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        imageView?.image = image
        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
