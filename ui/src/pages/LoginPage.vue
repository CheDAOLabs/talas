<template>
  <div>
    <div class="login ">
      <div class="imgbox"
           style="background: url(/images/login.jpg) no-repeat center center;background-size: cover;z-index: -1">
      </div>
      <SnowMask/>
      <div class="center">
        <div class="logo"><img src="@/assets/images/logo.png" alt=""></div>
        <div class="btns">
          <div class="btn1"><a href="javascript:;" @click="login_and_enter" v-loading="loading">WALLET LOGIN</a></div>
          <div class="btn2">
            <a href="#">social account</a>
            <a href="#">white papper</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import {mapState, mapActions, mapMutations} from 'vuex'
import {getAdventure} from "../system/graphql.js";
import {ElMessage} from "element-plus";
import SnowMask from "@/components/SnowMask.vue";

export default {
  name: 'LoginPage',
  components: {SnowMask},
  mounted() {

  },
  computed: mapState(['wallet_address']),
  data() {
    return {
      loading: false,
    }
  },
  methods: {
    ...mapMutations(['setAdventures', 'setAdventure', "setCurrPage",'resetState']),
    ...mapActions(['connect_wallet','loadAdventurer']),
    async login_and_enter() {
      this.resetState(false);
      // ElMessage({
      //   message: h('p', null, [
      //     h('span', null, 'Message can be '),
      //     h('i', { style: 'color: teal' }, 'VNode'),
      //   ]),
      // })

      if (this.loading) {
        return;
      }
      this.loading = true;
      try {
        await this.connect_wallet();
        let ads = await this.loadAdventurer();
        // let resp = await getAdventure(this.wallet_address);
        // console.log(resp)
        console.log("ads",ads)
        this.setAdventures(ads);
        this.setAdventure(ads[0])
        this.setCurrPage('adventure_list')
      } finally {
        this.loading = false
      }
    }
  }
}
</script>


<style scoped>

</style>