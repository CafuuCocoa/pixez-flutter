/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/network/api_client.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  final ApiClient client=apiClient;
  final int id;
  @observable
  UserDetail userDetail;
  @observable
  bool isFollow = false;
  @observable
  int value = 0;

  _UserStoreBase(this.id,{this.userDetail});

  @action
  Future<void> follow({bool needPrivate = false}) async {
    if (userDetail.user.is_followed) {
      try {
        Response response = await client.postUnFollowUser(id);

        userDetail.user.is_followed = false;
        isFollow = userDetail.user.is_followed;
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.badRequest) {}
      }
      return;
    }
    if (needPrivate) {
      try {
        Response response = await client.postFollowUser(id, 'private');
        userDetail.user.is_followed = true;
        isFollow = userDetail.user.is_followed;
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.badRequest) {}
      }
    } else {
      try {
        Response response = await client.postFollowUser(id, 'public');
        userDetail.user.is_followed = true;
        isFollow = userDetail.user.is_followed;
      } on DioError catch (e) {
        if (e.response != null &&
            e.response.statusCode == HttpStatus.badRequest) {}
      }
    }
  }

  @observable
  String errorMessage;

  @action
  Future<void> firstFetch() async {
    try {
      Response response = await client.getUser(id);
      UserDetail userDetail = UserDetail.fromJson(response.data);
      this.userDetail = userDetail;
      this.isFollow = this.userDetail.user.is_followed;
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == HttpStatus.notFound) {
        errorMessage = '404';
      } else {
        errorMessage = e.toString();
      }
    }
  }
}
