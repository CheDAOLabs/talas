<template>
  <div class="game map" v-loading="loading">

    <div class="userInfor2">
      <div class="bg">
        <div class="items1">
          <div class="item">
            <img src="@/assets/images/gold1.png" alt="">
            <span style="width: 80px;text-align: right">{{ adventurer.gold }}</span>
            <a href="javascript:;" class="add"></a>
          </div>
          <div class="item">
            <img src="@/assets/images/gold2.png" alt="">
            <span style="width: 80px;text-align: right">0</span>
            <a href="javascript:;" class="add"></a>
          </div>
        </div>
        <div class="items2">
          <div class="item">
            <img src="@/assets/images/gold3.png" alt="">
            <span>{{ getTypeCount(1) }}</span>
          </div>
          <div class="item">
            <img src="@/assets/images/gold4.png" alt="">
            <span>{{ getTypeCount(2) }}</span>
          </div>
          <div class="item">
            <img src="@/assets/images/gold5.png" alt="">
            <span>{{ getTypeCount(3) }}</span>
          </div>
        </div>
      </div>
    </div>


    <div class="mapContent zoomable-div">
      <div class="blocks">


        <div class="block block2 ui5 idle-animation" @click="onClickAttack">
          <div class="text">
            Dungeon<br/>Entrance
          </div>
          <div class="icon">
            <img src="@/assets/images/ui5.png" alt="">
          </div>
          <div class="dot"></div>
        </div>

        <div v-for="(res, index) in ResConfig" :key="index" class="">
          <div :class="'idle-animation block block1 ui'+getColorByType(res.type)" @click="onClickHarvesting"
               :style="{'left':res.x+'%','top':res.y+'%'}">
            <div class="text">
              {{ res.name }} <br>{{ getCanHarvestNum(res.id).toString() }} / {{ res.maxnum }}
            </div>
            <div class="icon">
              <img :src="'images/ui'+getColorByType(res.type)+'.png'" alt="">
            </div>
            <div class="dot"></div>
          </div>
        </div>

        <div class="centerPeople" @click="onClickSelf">
          <img src="@/assets/images/userimg.png" alt="">
        </div>

        <div class="home" @click="onClickBackHome"><img src="@/assets/images/home.png" alt=""></div>

        <div class="homePosition" @click="onClickBackHome"><i></i><img src="@/assets/images/home.png" alt=""></div>


      </div>
    </div>

    <BattleMask v-if="showBattleMask"/>
    <EventLogModal/>
    <AvatarComponent/>
    <FloatingBall/>
    <ShortcutBar/>
    <MissionCompleteModal v-if="showMissionCompleted"/>
    <RoleInformation :class="[showInformation?'show':'hide']"/>
    <DiedModal v-if="showDeadModal"/>
    <BeastInfoModal v-if="showBeastInfoModal"/>
    <BattleVictoryModal v-if="showBattleVictory"/>
    <BagComponent v-if="showBagModal"/>
  </div>
</template>


<script>
import $ from 'jquery';
import {mapActions, mapMutations, mapState} from "vuex";
import MissionCompleteModal from "../components/MissionCompleteModal.vue";
import ShortcutBar from "../components/ShortcutBar.vue";
import AvatarComponent from "../components/AvatarComponent.vue";
import RoleInformation from "../components/RoleInformation.vue";
import EventLogModal from "../components/EventLogModal.vue";
import FloatingBall from "../components/FloatingBall.vue";
import {ElMessage} from "element-plus";
import DiedModal from "../components/DiedModal.vue";
import {getColorByType, getResConfig, getResConfigById, getResConfigByType} from "@/config/res_conf.js";
import BeastInfoModal from "@/components/BeastInfoModal.vue";
import BattleMask from "@/components/BattleMask.vue";
import BattleVictoryModal from "@/components/BattleVictoryModal.vue";
import BagComponent from "@/components/BagComponent.vue";
import {playClickSound} from "@/utils/index.js";


export default {
  name: 'WorldPage',
  components: {
    BagComponent,
    BattleVictoryModal,
    BattleMask,
    BeastInfoModal,
    DiedModal,
    FloatingBall, EventLogModal, RoleInformation, AvatarComponent, MissionCompleteModal, ShortcutBar
  },
  computed: mapState(['wallet_address', "adventurer",
    "showMissionCompleted", "showDeadModal", "showInformation", "showBeastInfoModal", "showBattleMask",
    'showBattleVictory', 'showBagModal']),
  mounted() {
    var scale = 1.0; // 初始缩放比例
    var maxScale = 2.0; // 最大缩放比例
    var minScale = 0.5; // 最小缩放比例
    var step = 0.01; // 缩放步长

    $(".zoomable-div").on("wheel", function (event) {
      // 阻止页面滚动
      event.preventDefault();

      // 获取鼠标滚轮事件的 deltaY 值，正值表示向上滚动，负值表示向下滚动
      var delta = event.originalEvent.deltaY;

      // 计算新的缩放比例
      scale += (delta > 0) ? -step : step;

      // 限制缩放比例在最大和最小值之间
      if (scale > maxScale) {
        scale = maxScale;
      } else if (scale < minScale) {
        scale = minScale;
      }

      // 应用缩放
      $(this).css({
        transform: "scale(" + scale + ")"
      });
    });


  },
  data() {
    return {
      ResConfig: getResConfig(),
      loading: false
    };
  },
  methods: {
    getColorByType,
    ...mapMutations(['setShowMissionCompleted', 'setCurrPage', 'setShowInformation', 'setShowBeastInfoModal']),
    ...mapActions(['connect_wallet', 'getReceipt', 'attack', 'explore', 'flee', 'upgrade', 'harvesting']),
    async onClickHarvesting() {
      if (this.loading) {
        return;
      }
      playClickSound();

      const current_timestamp = Math.floor(Date.now() / 1000);
      const last_timestamp = this.adventurer.resources.last_timestamp;
      const count = (current_timestamp - last_timestamp) / 600;
      let num = count.toFixed(0);
      // console.log(num)
      if (num === '0') {
        ElMessage.error('Harvesting not available yet');
        return;
      }
      try {
        this.loading = true;
        await this.harvesting();
        this.setShowMissionCompleted(true);
      } finally {
        this.loading = false;
      }
    },
    async onClickAttack() {
      if (this.loading) {
        return;
      }
      playClickSound();
      let monster = this.adventurer.beastSpecs;
      if (monster) {
        // await this.attack(false, null);
        this.setShowBeastInfoModal(true)
      } else {
        if (this.adventurer.statUpgrades > 0) {
          ElMessage.error('Please upgrade your character first')
          this.setShowInformation(true);
        } else {
          try {
            this.loading = true;
            await this.explore(true);
          } finally {
            this.loading = false;
          }
        }
      }

    },
    async onClickBackHome() {
      playClickSound();
      this.setCurrPage('main');
    },
    getCanHarvestNum(id) {
      if (id === undefined) {
        return 0
      }
      const current_timestamp = Math.floor(Date.now() / 1000);
      const last_timestamp = this.adventurer.resources.last_timestamp;
      const count = (current_timestamp - last_timestamp) / 600;
      const config = getResConfigById(id);
      if (config.refresh === '0') {
        return 0;
      }
      let num = (Number)(count.toFixed(0)) * (Number)(config.refresh);
      if (num >= config.maxnum) {
        num = config.maxnum;
      }
      // console.log("getCanHarvestNum",config, id,num,current_timestamp,last_timestamp);
      console.log('aaa', (Number)(num))
      return (Number)(num);
      // return 999;
    },
    getTypeCount(type) {
      let configs = getResConfigByType(type);

      let all = 0;
      for (let i = 0; i < configs.length; i++) {
        let config = configs[i];
        all += this.getCanHarvestNum(config.id);
      }
      // console.log("configs", configs);

      return all;
    },
    onClickSelf() {
      playClickSound();
      this.setShowInformation(true)
    }
  }
}

</script>


<style scoped>
.some {
  margin-top: 2px;
  height: 32px;
  width: 50px;
  text-align: right;
  background: #0a0a0a;
  border: 2px solid #000000;
}

.mapContent .blocks .block {
  transform: scale(1);
}

.mapContent .blocks .block .text {
  width: 120px;
  left: -13px;
}
</style>