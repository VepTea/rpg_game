import 'package:rpg_game/rpg_game.dart' as rpg_game;
import 'dart:io'; //입력 받기 위해서 필요함.
import 'dart:math'; //랜덤 함수 사용을 위해서 필요함.

Character loadCharacterStats(RpgGame game) {
  //캐릭터 스탯 파일 불러오기기
  // 이 함수는 RpgGame 객체를 인자로 받아서 캐릭터의 스탯을 파일에서 읽어서 캐릭터 객체를 생성한다.
  // 이 함수는 main() 함수에서 호출된다.

  // 캐릭터의 스탯은 bin/characters.txt 파일에 저장되어 있다
  // 캐릭터의 이름은 어디서 받냐면 먼저 main() 함수에서 RpgGame game 객체를 생성하고,
  // 그 game 객체의 characterNaming() 메서드를 호출한다.
  // 그 후에 characterNaming()의 반환값(String타입임)으로 이름을 입력받아서 진짜 캐릭터 객체를 생성한다.
  try {
    final file = File('bin/characters.txt');
    final contents = file.readAsStringSync().trim(); // 파일 내용 읽기
    final stats = contents.split(','); // CSV 분리
    if (stats.length != 3) throw FormatException('Invalid character data');

    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);

    String name = game.characterNaming();
    // RpgGame 객체의 characterNaming() 메서드를 호출해서 캐릭터 이름을 입력받는다.
    Character character = Character(name, health, attack, defense);
    //이 줄이 캐릭터 객체를 생성하는 “본진” 로직임!
    // 그리고 이 캐릭터는 game.character = ...에 저장돼서 게임에서 쓰임.
    return character;
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}

abstract class Object {     //■■■■■ abstract 클래스인 Object 정의  (Character, Monster 모두 이 클래스를 상속받음) ■■■■■
  String name = '무명';
  int health = 0; //체력
  int damage = 0; //공격력
  int defense = 0; //방어력
  void showStatus() {
    print("$name - 체력: $health, 공격력: $damage, 방어력: $defense");
  }
}

class Character implements Object {  //■■■■■ Character 클래스 정의 (Object 클래스 상속받았음) ■■■■■
  @override
  String name; //이름 나중에 입력받아서 캐릭터 객체 생성해야 됨 ㅎ
  @override
  int health; //오버라이드 됨
  @override
  int damage; //오버라이드됨
  @override
  int defense; //방어력 멤버 변수 추가

  Character(    this.name,
    this.health,
    this.damage,
    this.defense,
  ); //생성자: 이름을 입력받아 초기화

  @override
  void showStatus() {
    print("$name용사님 - 체력: $health, 공격력: $damage, 방어력: $defense");
    //캐릭터의 상태를 출력하는 메서드
    //호출될 위치는 RpgGame 클래스의 battle에서 character,monster 한대씩 때리고 나서 호출됨.
  }

  void attackMonster(Monster stagedMonster) {
    // 현재 등장해 있는 몬스터의 hp변수 값을 캐릭터의 공격력만큼 빼준다.
    print("--------------------------------------------------------");
    print("체력 ${stagedMonster.health}있는 ${stagedMonster.name}에게 -$damage 만큼 피해를 줬다는거 아니겠음~?");
    //이 stagedMonster는 RpgGame 클래스의 멤버변수로 선언되어 있음.
    stagedMonster.health -= damage; //소환된 몬스터의 hp에서 캐릭터의 공격력만큼 감소시킨다.
    if (stagedMonster.health > 0) {
      print("${stagedMonster.name}의 hp가 ${stagedMonster.health}로 날라가 버렸다는 거 아니겠음~? 침하하~");//몬스터의 hp를 출력한다.
    } else {
      print("${stagedMonster.name} 이거 아주 개털이 됐다~~ 말이거든요잉~!");
      //몬스터의 hp가 0 이하가 되면 몬스터가 쓰러졌다고 출력한다.
    }
  }

  void defend(Monster stagedMonster) {
    print("--------------------------------------------------------");
    print("아니 우리 용사님이~ 긍께 방어도 으잉? 아주 기깔라게 하시는구만 말이여~ 방어두 기술이다~~ 이말이여~");
    // 너무 방어를 완벽하게 해서 오히려 체력이 상승. 말이 안되지만 원래 두곡리 퐌타지 RPG에서는 가능
    //몬스터의 공격력은 RpgGame 클래스의 stagedMonster 객체에서 가져온것임
    int healPoint = Random().nextInt(stagedMonster.maxDamage ~/ 3) + 1;
    health += healPoint; // 몬스터의 공격력의 1~ 1/3만큼 랜덤으로 체력을 회복한다.
    print("용사님이 을~매나 편안했으면 체력을 +$healPoint 만큼 회복했다는거 아니겄슈~?");
  }
}

class Monster implements Object {    //■■■■■ Monster 클래스 정의 (Object 클래스 상속받았음) ■■■■■
  @override
  String name; //이름 나중에 입력받아서 몬스터 객체 생성해야 됨 ㅎ
  @override
  int health;    //객체 생성자에서 초기화
  int maxDamage; //랜덤으로 지정할 공격력 범위 최대값(몬스터마다 다름)
  @override
  int defense = 0; //몬스터는 방어력은 없다고 가정함. 몬스터는 공격만 한다.
  @override
  late int damage; // 진짜 몬스터의 공격력(랜덤으로 지정됨, attackCharacter 메서드에서 매 공격시마다 새롭게 정해짐)

  Monster(this.name, this.health, this.maxDamage); //생성자: 이름, 체력, 공격력을 입력받아 초기화

  @override
  void showStatus() {    //몬스터의 상태를 출력하는 메서드
    //호출될 위치는 RpgGame 클래스의 battle메서드에서 character, monster 둘이 한대씩 때리고 나서 호출됨.
    print("$name - 체력: $health, 최대공격력: $maxDamage");
  }

  void attackCharacter(Character character) { // 몬스터가 플레이어를 공격하는 메서드
    //플레이어를 공격하려면 플레이어의 health를 몬스터의 공격력만큼 감소시켜야 함.
    //그렇다면 몬스터의 공격력을 먼저랜덤으로 정해야함.(매 공격마다 새롭게 정해야함)
    //몬스터의 공격력의 조건: player의 방어력< 몬스터의 공격력 <= 몬스터의 최대공격력
    damage = Random().nextInt(maxDamage); // 몬스터의 공격력을 랜덤으로 설정한다.
    if (damage <= character.defense) {    //몬스터의 공격력이 플레이어의 방어력보다 낮게 나오면
      damage = character.defense + 1;     // 그냥 player의 방어력보다 +1을 더해서 재설정한다.
    } 

    character.health -=
        (damage - character.defense); //플레이어의 hp에서 (몬스터의 공격력-플레이어 방어력)만큼 감소시킨다.
    print("--------------------------------------------------------");
    print("아이고오~~~!!!우리 용사님이이 글쎄~ $name에게 -$damage 만큼 공격을 그냥 받으셨는데,");
    print("용사님이 몸이 딴딴해가지고 피가 -${damage - character.defense}밖에 안깎여가지고 ");
    print("피통이 ${character.health}가 남았다는거 아니겠음~?");
    //몬스터가 플레이어를 공격했을 때 출력되는 메시지
  }
}

class RpgGame { //■■■■■ RpgGame 클래스 정의 (게임의 전체 로직(게임의 상태, 캐릭터, 몬스터 등을)관리하는 클래스) ■■■■■
  late Character character; // 캐릭터 객체를 저장할 변수. 초기값은 null로 설정됨. 나중에 loadCharacterStats() 메서드에서 캐릭터 객체를 생성해서 대입함.
  late Monster stagedMonster; //소환된 몬스터를 저장할 변수. 몬스터와 전투를 할 때 사용됨. 초기값은 null로 설정됨. 나중에 getRandomMonster() 메서드에서 랜덤으로 몬스터를 소환해서 대입함.

  List<Monster> monsterList = [    //몬스터 목록
    Monster('한대 맞으면 나가리 되는 말벌', 10, 25),
    Monster('더러운 러브버그', 15, 20),
    Monster('무시무시한 거미', 25, 20),
    Monster('사나운 황소개구리', 30, 25),
  ];
  int monsterClearCount = 0;  //몬스터 처치 횟수, 물리친 몬스터의 갯수보다 작아야 함. 추후에 처치 횟수가 List의 length와 같아지면 게임 클리어로 간주함.
  late final int initialMonsterListLength = monsterList.length;
  // 초기의 몬스터 목록에 있는 몬스터의 수! 이걸 왜 알아야하냐면 나중에 게임 클리어 판단할 때 필요하다.
  // 게임시작할때 정해진 몬스터의 갯수만큼 다 쓰러뜨렸는지 확인하기 위해서 갯수를 저장해놓는것이다.
  //late를 쓴 이유는, 이 값은 클래스가 완전히 생성된 뒤에야 알 수 있는 값 // 몬스터 목록이 실제로 생성되고 난 후에야 알 수 있는 값이기 때문에 late로 선언한다. 
  //멤버변수는 두개가 동시에 이렇게 생성될 수 없다고 함. 그래서 객체가 생기고 monsterList가 생성된 후에 초기화된다.
  //"변경되지 않게"는 하고 싶기 때문에 final을 같이 쓰는 거
  bool wantsToContinue = true;  //유저가 게임을 계속 진행하고 싶은 의사. 몬스터 처치 후에 물어봄 이 클래스의 continue 메서드에서 변경 되는 애임.
  
  RpgGame() { // 임시로 기본값을 넣어줍니다. (이후 characterNaming에서 이름을 바꿉니다)
    character = Character('용사', 0, 0, 0); //이 줄은 RpgGame 객체를 생성할때, 자동으로 이 character 객체가 생성되게 한다.
  }// 이렇게 생긴 생성자는 생소할 수 있지만, 생성자와 {}중괄호를 같이 쓰면 생성하는 동시에 괄호안에 있는 작업을 수행한다.
  // Dart에서는 클래스의 생성자에서 멤버 변수를 초기화할 때 주로 사용된다.

  String characterNaming() {//메서드: Character 이름 등록 해주기
    print("--------------------------------------------------------");
    print("'만흥리 벌레 때려잡는 뒤집어지는 호들갑 용사의 킹받는 모험 시리즈 : 1 '에 오신 것을 환영합니다요");
    while (true) {
      print("--------------------------------------------------------");
      print("캐릭터의 이름을 입력하시라요");
      String? characterName = stdin.readLineSync() ?? ''; //사용자로부터 캐릭터 이름 입력 받기
      //그런데, 입력 받은 값이 a-zA-Z가-힣일때만 바꿀 수 있게 해주고 null이나 특수문자있으면 다시 설정하라고 해야함. ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■!이건 나중에 꼭 해야함

      try {
        character.name = characterName; //캐릭터 이름을 입력받아서 character 객체의 name 변수에 저장
        break; // 정상적으로 입력되면 반복문 종료
      } catch (e) {
        print("--------------------------------------------------------");
        print("잘못된 입력이올시다. 다시 시도하시라요."); //예외 처리: 입력값이 null인 경우 다시 입력 받기
      }
    }
    print("--------------------------------------------------------");
    print("용사님의 존함이 ${character.name}으로 설정되었다~ 그 말이거든요잉~?");
    return character.name; //입력받은 캐릭터 이름을 반환한다.
    //이제 이 캐릭터 이름을 가지고 loadCharacterStats() (우리 코드 맨 위에 있는 함수)의 매개변수로 값이 가서 캐릭터 객체를 생성할 때 이름을 제공한다.
    //이렇게 생성된 캐릭터 객체는 RpgGame 클래스의 character 변수에 저장된다.
  }

  void gameStart() {    //메서드: 게임 시작 해주기
    print("--------------------------------------------------------");
    print("게임을 시작합니다!");
    print(
      "${character.name} - 체력: ${character.health} , 공격력: ${character.damage} , 방어력: ${character.defense}",
    );
  }

  void getRandomMonster() {    //메서드: 몬스터 소환하기 - 몬스토리스트에서 남은 몬스터 중 랜덤으로 한 마리를 소환해 stagedMonster에 할당한다.
     print("남은 몬스터 리스트: ${monsterList.map((m) => m.name).toList()}");
  print("남은 몬스터 수: ${monsterList.length}");
    stagedMonster =
        monsterList[Random().nextInt(
          monsterList.length,
        )]; //몬스터리스트에 있는 몬스터 중 랜덤으로 하나를 선택해서 stagedMonster로 대입한다.
    print("--------------------------------------------------------");
    print("용사님~~~살려주시라요~~~!!!");
    print("새로운 몬스터가 나타나 위협하고 있단 말이거든요잉~~ㄷ아아아아아악!!!!꺍");
    print(
      "소환된 몬스터: ${stagedMonster.name} - 체력: ${stagedMonster.health}, 최대공격력: ${stagedMonster.maxDamage}",
    );
  }

  void battle() {//메서드: 몬스터와 전투하기
    // 플레이어와 몬스터가 번갈아가며 턴을 진행한다. 몬스터의 체력이 0 이하가 되면 전투 종료.
    
    //몬스터리스트에 랜덤으로 몬스터를 하나 선택한다.-해결함
    //그 몬스터가 stagedMonster로 대입된다.-해결함
    // stagedMonster와 character 객체가 전투를 시작한다.어떻게?  playerTurn()과 monsterTurn()을 반복한다.
    //
    // player의 턴에서는 입력값을 받아 1이면 공격 메서드를 호출하고, 2면 방어 메서드를 호출한다.
    //        공격 메서드는 stagedMonster의 hp를 player의 공격력만큼 감소시킨다.
    // gmae 클래스의  battle 메서드를 실행시키면,
    // 아래가 반복된다.: (언제까지? 일단 stagedMonster가 hp< 0일때까지
    print("--------------------------------------------------------");
    print("전투가 시작되었단 말이거든요잉~~~!!!");
    while (stagedMonster.health > 0) {
      // 무엇을 반복할거냐면 이런 거다.
      //  player의 턴이라는 함수를 실행한다.
      playerTurn(); // 플레이어의 턴을 실행한다

    if (stagedMonster.health <= 0) {
         //  몬스터가 죽었는지 먼저 체크하고 종료
      break;
    }
      stagedMonster.attackCharacter(character); // 몬스터의 턴을 실행한다. 몬스터가 플레이어를 공격한다.
      character.showStatus(); // 플레이어의 상태를 출력한다.
      stagedMonster.showStatus(); // 몬스터의 상태를 출력한다.
    }

    
    // 전투가 끝난 몬스터는 리스트에서 제거하고, 처치 횟수를 증가시킨다.
    monsterList.remove(
      stagedMonster,
    ); //이제 소환된 몬스터는 몬스터리스트에서 필요 없어~ 삭제! 이제 소환할 때, 중복되는 애들이 소환되지 않을거임
    monsterClearCount++; // 몬스터 처치 횟수를 1 증가시킨다.
    print("--------------------------------------------------------");
    print("축하드리옵니다 나~리~!!! 벌레를 $monsterClearCount마리 째 때려잡으셨다는 말이거든요잉~");
  }

  void playerTurn() {// 플레이어의 턴: 공격 또는 방어를 선택한다.
    
    print('${character.name}의 턴이거든요잉~~~ ');
    // 	입력값 조건이 1번일 때:
    // 	캐릭터 객체의 attack 메서드를 실행해서 game 클래스의
    // 	stagedMonster 객체(game클래스의 멤버변수 중 하나)의 hp값을 바꾸고싶다.

    // 	입력값 조건이 2번일 때:
    // 	캐릭터 객체의 defend 메서드를 실행해서
    // 	캐릭터 객체의 hp를 올려준다.
    try {
      //일단 똑바로 안쓸 수 있으니깐, try 로 예외가 나올 수 있는 코드블록임을 인지하도록 하자
      print("--------------------------------------------------------");
      print("어떡하시렵니까? 용사 나으리~? (1: 공격, 2: 방어)");
      String? input = stdin.readLineSync(); // 선택 입력 받기
      switch (input) {
        case '1': //1을 입력받은 경우
          character.attackMonster(stagedMonster);
          // 캐릭터의 attack 메서드를 실행해서 stagedMonster의 hp를 감소시킨다.
          break; // switch문을 빠져나온다.
        case '2': //2를 입력받은 경우
          character.defend(stagedMonster); // 캐릭터의 defend 메서드를 실행한다.
          break; // switch문을 빠져나온다.
        default: // 그 외의 입력값을 받은 경우
          print("잘못된 입력입니다. 똑바로 시도하시라요!"); // 잘못된 입력에 대한 예외 처리
      }
    } catch (e) {
      print("잘못된 입력입니다. 다시 시도하시라요.");
    }
  }

  void continueGame() {// 전투 후, 게임을 계속할지 플레이어에게 묻는다.
    
    while (true) {
      print("--------------------------------------------------------");
      print("앞으로 더 나가볼까요 나으리~? 계속 진행하실랑가요? (y/n)");
      String? input = stdin.readLineSync() ?? ''; //사용자로부터 입력 받기
      switch (input) {
        case 'y': //case 문 쓸때는 or(||) 연산자를 쓰는게 말이 안된다고 함.이게 맞다함.
        case 'Y':
          wantsToContinue = true; //게임을 계속 진행하고 싶은 의사(wantsToContinue)를 true로 설정
          print("게임을 계속 진행합니다.");
          break; //이걸로 switch 조건문을 나간 후, 바깥에 있는 break 한 번 더 있는걸로 while 반복문도 나가야함.
        case 'n':
        case 'N':
          wantsToContinue =
              false; //게임을 계속 진행하고 싶은 의사(wantsToContinue)를 false로 설정
          print("고생하셨습니다 나으리~ 게임을 저장하실랑가요잉?");
          // 나중에 게임 저장하는 로직 추가해야함.
          break;
        default:
          print("잘못된 입력입니다.");
          continue; // 다시 질문해야함!
      }
      break; //이걸로 while 반복문 나감!
    }
  }

  void gameClear() {    // 모든 몬스터를 처치하면 호출된다.
    print("축하합니다요~~~ 아주 그냥 모오든 벌레들을 싸-악 쓸어버리셨습니다요~ 두곡리 마을에는 평화가 찾아왔다 이말이거든요잉~");
    print("즐겨주셔서 감사합니다잉~");
  }

  void gameOver() {
        // 플레이어가 사망하면 호출된다.
    if (character.health < 0) {
      print("아이고? 용사님 돌아가셨네? 용사님~ 일어나세요~ 일하셔야죠~ 나중에 다시 도전하세요잉~");
    }
  }

  void saveGame() {
    
    // TODO: 게임 저장 기능 구현 필요
  }
}

void main() {
  RpgGame game = RpgGame(); //■■■■■ 게임 객체 생성
  game.character = loadCharacterStats(game); // 캐릭터 스탯을 파일에서 읽어와 적용
  // 이 안에 캐릭터 이름을 넣어주는 characterNaming() 메서드가 호출된다.
  game.gameStart(); //■■■■■■■■■■■■■■ 게임 시작 메서드 호출
  do {
    game.getRandomMonster(); //■■■■■ 랜덤으로 몬스터 소환 메서드
    game.battle(); // ■■■■■■■■■■■■■■■ 턴제 전투 시작 메서드
    game.continueGame(); // ■■■■■■■■ 전투 계속할건지 묻기 메서드
  } while (game.wantsToContinue &&
      game.monsterClearCount < game.initialMonsterListLength);
  // 플레이어가 계속을 선택하고, 모든 몬스터를 처치하지 않은 동안 반복


  game.gameClear();
}
