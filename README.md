# infobright4.0.7
infobright是一款列式数据库分析开源软件，基于mysql5.1版本进行开发，支持SQL书写，在分析每日亿级别下数据的列式分析汇总比传统行式数据库有非常大的提高
## 优点
1. 亿级别以下的数据分析、数据汇总非常快，相对于hbase该数据库架构简单，快速试用且属于单机式架构，对于PB级别以下数据基本都可以应对
2. 数据压缩比例非常高，相对于innodb减少20-30倍，相对于archive减少3倍，且解压缩速度非常快
3. 数据计算准确度高

## infobright_backup.sh
使用rsync对数据库进行同步备份，并可模仿主从功能
## infobright_install.sh
infobright安装脚本
## track
基于列式数据库infobright搭建的在线分析任务平台，架构使用mysql+php模式，支持在线新建自动分析任务，系统自动运算并产生结果
