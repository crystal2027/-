package org.fisco.bcos.asset.client;

import java.util.*;

import java.io.*;

//实现命令行交互类CLI
public class CLI{

    private Map<String, String> map;
    private Scanner scanner;
    private boolean status;
    private String current;
    private String path;

//接口介绍：
//1、getStatus()获得状态；
    public CLI(){
        path = "test.txt";
        status = true;
        scanner = new Scanner(System.in);
        map = new HashMap<String, String>();
        read_file();
    }

    public boolean getStatus(){
        return this.status;
    }

    public String getCurrent(){
        return this.current;
    }

    public void setCurrentNull(){
        this.current = null;
    }

//3、getMap()：CLI类中用一个私有变量Map来暂时存储用户的ID和密码，getMap函数可以用来获取Map中存储的ID和密码
    public Map<String, String> getMap(){
        return this.map;
    }

//4、read_file():读文件，这里是从test.txt文件中读取用户ID和密码并暂时存储进Map中；5、write_file():写文件，从Map结构中读取用户ID和密码并按照“ID   密码/n”这样的格式写进之地路径下的文件，这里是test.txt
    public void read_file(){
        try{
            FileReader fd = new FileReader(path);
            BufferedReader br = new BufferedReader(fd);
            String s1 = null;
            while((s1 = br.readLine()) != null) {
                String[] temp = s1.split("  ");
                map.put(temp[0],temp[1]);
            }
           br.close();
           fd.close();
        } catch (IOException e) {
            System.out.println("Error:" + e.getMessage());
        }
    }

	public void write_file()
	{
		try{
            File file = new File(path);
            FileWriter fw = new FileWriter(file,false);
            for (String key : map.keySet()) {
                String temp = key+"  "+map.get(key);
                fw.write(temp+"\n");
            }
            fw.flush();
            fw.close();    

        } catch (IOException e) {
            System.out.println("Error:" + e.getMessage());
        }
	}

//6、login():bool类型，返回true时登陆成功。在命令行中出现登陆界面，可以选择登陆、注册或者退出。选择登陆时，函数会读取用户输入的ID和密码，并与Map中从test.txt读取的后台记录进行对比。选择注册时，函数会读取用户输入的ID和密码并存进Map
    public boolean login()
    {
        int choice;
        String acc, pass, again;
        Console console = System.console();
        System.out.println("----------Welcome----------\n");
        System.out.println("----------Proudly produced by 18342081欧阳志强、18340021陈雪琪、18342079聂羽丞\n");
        System.out.println("Now enter:\n1:LOG IN\t2:REGISTER\t0:quit()");
        if (scanner.hasNextInt()){
            choice = scanner.nextInt();
            switch(choice){
                case 0:
                    this.status = false;
                    return false;

                case 1:
                    acc = (String)scanner.nextLine();
                    System.out.print("----------LOGIN登录----------\nID用户名: ");
                    acc = (String)scanner.nextLine();
                    System.out.print("Password密码:");
                    pass = new String(console.readPassword());
                    if(map.get(acc)!=null && map.get(acc).compareTo(pass) == 0) {
                        current = acc;
                        System.out.print("Log in success! 登陆成功！");
                        again = (String)scanner.nextLine();
                        return true;
                    } else {
                        System.out.print("No account or wrong password! 用户不存在或密码错误！");
                        again = (String)scanner.nextLine();
                        return false;
                    } 

                case 2:
                    acc = (String)scanner.nextLine();
                    System.out.print("----------REGISTER注册----------\n ID用户名: ");
                    acc = (String)scanner.nextLine();
                    System.out.print("Password密码:");
                    pass = new String(console.readPassword());
                    System.out.print("Reinput再次确认密码:");
                    again = new String(console.readPassword());
                    if(pass.compareTo(again)==0 && map.get(acc)==null){
                        map.put(acc,pass);
                        write_file();
                        read_file();
                        System.out.print("Register success! 注册成功！");
                        again = (String)scanner.nextLine();
                        return false;
                    } else {
                        System.out.print("Register failed! 注册失败！");
                        again = (String)scanner.nextLine();
                        return false;
                    }

                default:
                    System.out.print("Error:Invalid input! 无效输入！");
                    again = (String)scanner.nextLine();
                    return false;
            }
        }
        else {
            System.out.print("Error:Invalid input! 无效输入！");
            return false;
        }
    }

//clear():清空命令行
    public void clear(){
        for (int i = 0; i < 20; ++i) System.out.print("\n");
    }

//msg():登陆成功后用于输出提供哪些功能。注：这里具体有哪些功能还要看后端实现了，后期可以改，不重要
    public void msg(){
        System.out.print("Dear "+current+", please choose a followed survey\n");
        System.out.println("1: 查询本人信用额度.\n2: 与其他用户进行交易.\n3: 融资/向银行贷款.\n4: 欠条拆分\n5: 转账/还贷.\n6: 查询交易.\n0: 退出登录\n\n");

    }

}