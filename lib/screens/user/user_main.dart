import 'package:flutter/material.dart';
import 'package:country_icons/country_icons.dart';

class UserMain extends StatelessWidget {
  UserMain({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();
  final double cardWidth = 400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유저'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: '유저이메일',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // todo : 검색실행
                  },
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Row(
                children: [
                  Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: SizedBox(
                            width: cardWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 130.0,
                                      height: 130.0,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage("https://www.helpguide.org/wp-content/uploads/king-charles-spaniel-resting-head.jpg"),
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              // todo: 설정된 언어로 국가 표시 - 국기는 앱 내에 image로 저장하기
                                              image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_South_Korea.svg/800px-Flag_of_South_Korea.svg.png"), // todo: 앱 로그인시 country_list_pick 사용할 것
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const Text('Danny Park', textScaleFactor: 2),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context).colorScheme.primaryContainer
                                      ),
                                      child: Text('Premium', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),),
                                    ),
                                    // todo: 비구독유저 설정 : text-'Free', background-secondary, textColor-onSecondary
                                  ],
                                ),
                                const Divider(height: 50),
                                getInfoRow('이메일', 'kammaii@gmail.com'),
                                const SizedBox(height: 10),
                                getInfoRow('가입일', '0000-00-00'),
                                const SizedBox(height: 10),
                                getInfoRow('최종로그인', '0000-00-00'),
                                const Divider(height: 50),
                                getInfoRow('구독시작일', '0000-00-00'),
                                const SizedBox(height: 10),
                                getInfoRow('구독종료일', '0000-00-00'),
                                const Divider(height: 50),
                                getInfoRow('학습목적', '여행'),
                                const SizedBox(height: 10),
                                getInfoRow('완료레슨', '00개'),
                                const SizedBox(height: 10),
                                getInfoRow('즐겨찾기', '00개'),
                                const SizedBox(height: 10),
                                getInfoRow('메시지수신', '허용'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: (){}, child: const Text('교정내역 보기')), // todo: 교정으로 이동해서 유저이메일로 query
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: (){}, child: const Text('구매정보 보기')),
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: (){}, child: const Text('유저정보 수정하기')),
                          const SizedBox(width: 10),
                        ],
                      )
                    ],
                  ),
                  const Expanded(child: Text('')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoRow(String title, String info) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        const SizedBox(width: 20),
        Text(info, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
